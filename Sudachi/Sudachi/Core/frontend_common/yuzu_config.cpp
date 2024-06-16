// SPDX-FileCopyrightText: 2023 yuzu Emulator Project
// SPDX-License-Identifier: GPL-2.0-or-later

#include <algorithm>
#include <array>
#include "common/fs/fs.h"
#include "common/fs/path_util.h"
#include "common/logging/log.h"
#include "common/settings.h"
#include "common/settings_common.h"
#include "common/settings_enums.h"
#include "frontend_common/yuzu_config.h"
#include "core/core.h"
#include "core/hle/service/acc/profile_manager.h"
#include "hid_core/resources/npad/npad.h"
#include "network/network.h"

#include <boost/algorithm/string/replace.hpp>

#include "common/string_util.h"

namespace FS = Common::FS;

YuzuConfig::YuzuConfig(const ConfigType config_type)
    : type(config_type), global{config_type == ConfigType::GlobalConfig} {}

void YuzuConfig::Initialize(const std::string& config_name) {
    const std::filesystem::path fs_config_loc = FS::GetYuzuPath(FS::YuzuPath::ConfigDir);
    const auto config_file = fmt::format("{}.ini", config_name);

    switch (type) {
    case ConfigType::GlobalConfig:
        config_loc = FS::PathToUTF8String(fs_config_loc / config_file);
        void(FS::CreateParentDir(config_loc));
        SetUpIni();
        Reload();
        break;
    case ConfigType::PerGameConfig:
        config_loc = FS::PathToUTF8String(fs_config_loc / "custom" / FS::ToU8String(config_file));
        void(FS::CreateParentDir(config_loc));
        SetUpIni();
        Reload();
        break;
    case ConfigType::InputProfile:
        config_loc = FS::PathToUTF8String(fs_config_loc / "input" / config_file);
        void(FS::CreateParentDir(config_loc));
        SetUpIni();
        break;
    }
}

void YuzuConfig::Initialize(const std::optional<std::string> config_path) {
    const std::filesystem::path default_sdl_config_path =
        FS::GetYuzuPath(FS::YuzuPath::ConfigDir) / "sdl2-config.ini";
    config_loc = config_path.value_or(FS::PathToUTF8String(default_sdl_config_path));
    void(FS::CreateParentDir(config_loc));
    SetUpIni();
    Reload();
}

void YuzuConfig::WriteToIni() const {
    std::string config_type;
    switch (type) {
    case ConfigType::GlobalConfig:
        config_type = "Global";
        break;
    case ConfigType::PerGameConfig:
        config_type = "Game Specific";
        break;
    case ConfigType::InputProfile:
        config_type = "Input Profile";
        break;
    }
    LOG_INFO(Config, "Writing {} configuration to: {}", config_type, config_loc);
    FILE* fp = nullptr;
#ifdef _WIN32
    fp = _wfopen(Common::UTF8ToUTF16W(config_loc).data(), L"wb");
#else
    fp = fopen(config_loc.c_str(), "wb");
#endif

    if (fp == nullptr) {
        LOG_ERROR(Frontend, "Config file could not be saved!");
        return;
    }

    CSimpleIniA::FileWriter writer(fp);
    const SI_Error rc = config->Save(writer, false);
    if (rc < 0) {
        LOG_ERROR(Frontend, "Config file could not be saved!");
    }
    fclose(fp);
}

void YuzuConfig::SetUpIni() {
    config = std::make_unique<CSimpleIniA>();
    config->SetUnicode(true);
    config->SetSpaces(false);

    FILE* fp = nullptr;
#ifdef _WIN32
    _wfopen_s(&fp, Common::UTF8ToUTF16W(config_loc).data(), L"rb, ccs=UTF-8");
    if (fp == nullptr) {
        fp = _wfopen(Common::UTF8ToUTF16W(config_loc).data(), L"wb, ccs=UTF-8");
    }
#else
    fp = fopen(config_loc.c_str(), "rb");
    if (fp == nullptr) {
        fp = fopen(config_loc.c_str(), "wb");
    }
#endif

    if (fp == nullptr) {
        LOG_ERROR(Frontend, "Config file could not be loaded!");
        return;
    }

    if (SI_Error rc = config->LoadFile(fp); rc < 0) {
        LOG_ERROR(Frontend, "Config file could not be loaded!");
    }
    fclose(fp);
}

bool YuzuConfig::IsCustomConfig() const {
    return type == ConfigType::PerGameConfig;
}

void YuzuConfig::ReadPlayerValues(const std::size_t player_index) {
    std::string player_prefix;
    if (type != ConfigType::InputProfile) {
        player_prefix.append("player_").append(ToString(player_index)).append("_");
    }

    const auto profile_name = ReadStringSetting(std::string(player_prefix).append("profile_name"));

    auto& player = YuzuSettings::values.players.GetValue()[player_index];
    if (IsCustomConfig()) {
        if (profile_name.empty()) {
            // Use the global input config
            player = YuzuSettings::values.players.GetValue(true)[player_index];
            player.profile_name = "";
            return;
        }
        player.profile_name = profile_name;
    }

    if (player_prefix.empty() && YuzuSettings::IsConfiguringGlobal()) {
        const auto controller = static_cast<YuzuSettings::ControllerType>(
            ReadIntegerSetting(std::string(player_prefix).append("type"),
                               static_cast<u8>(YuzuSettings::ControllerType::ProController)));

        if (controller == YuzuSettings::ControllerType::LeftJoycon ||
            controller == YuzuSettings::ControllerType::RightJoycon) {
            player.controller_type = controller;
        }
    } else {
        if (global) {
            auto& player_global = YuzuSettings::values.players.GetValue(true)[player_index];
            player_global.profile_name = profile_name;
        }
        std::string connected_key = player_prefix;
        player.connected = ReadBooleanSetting(connected_key.append("connected"),
                                              std::make_optional(player_index == 0));

        player.controller_type = static_cast<YuzuSettings::ControllerType>(
            ReadIntegerSetting(std::string(player_prefix).append("type"),
                               static_cast<u8>(YuzuSettings::ControllerType::ProController)));

        player.vibration_enabled = ReadBooleanSetting(
            std::string(player_prefix).append("vibration_enabled"), std::make_optional(true));

        player.vibration_strength = static_cast<int>(
            ReadIntegerSetting(std::string(player_prefix).append("vibration_strength"), 100));

        player.body_color_left = static_cast<u32>(ReadIntegerSetting(
            std::string(player_prefix).append("body_color_left"), YuzuSettings::JOYCON_BODY_NEON_BLUE));
        player.body_color_right = static_cast<u32>(ReadIntegerSetting(
            std::string(player_prefix).append("body_color_right"), YuzuSettings::JOYCON_BODY_NEON_RED));
        player.button_color_left = static_cast<u32>(
            ReadIntegerSetting(std::string(player_prefix).append("button_color_left"),
                               YuzuSettings::JOYCON_BUTTONS_NEON_BLUE));
        player.button_color_right = static_cast<u32>(
            ReadIntegerSetting(std::string(player_prefix).append("button_color_right"),
                               YuzuSettings::JOYCON_BUTTONS_NEON_RED));
    }
}

void YuzuConfig::ReadTouchscreenValues() {
    YuzuSettings::values.touchscreen.enabled =
        ReadBooleanSetting(std::string("touchscreen_enabled"), std::make_optional(true));
    YuzuSettings::values.touchscreen.rotation_angle =
        static_cast<u32>(ReadIntegerSetting(std::string("touchscreen_angle"), 0));
    YuzuSettings::values.touchscreen.diameter_x =
        static_cast<u32>(ReadIntegerSetting(std::string("touchscreen_diameter_x"), 90));
    YuzuSettings::values.touchscreen.diameter_y =
        static_cast<u32>(ReadIntegerSetting(std::string("touchscreen_diameter_y"), 90));
}

void YuzuConfig::ReadAudioValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Audio));

    ReadCategory(YuzuSettings::Category::Audio);
    ReadCategory(YuzuSettings::Category::UiAudio);

    EndGroup();
}

void YuzuConfig::ReadControlValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Controls));

    ReadCategory(YuzuSettings::Category::Controls);

    YuzuSettings::values.players.SetGlobal(!IsCustomConfig());
    for (std::size_t p = 0; p < YuzuSettings::values.players.GetValue().size(); ++p) {
        ReadPlayerValues(p);
    }

    // Disable docked mode if handheld is selected
    const auto controller_type = YuzuSettings::values.players.GetValue()[0].controller_type;
    if (controller_type == YuzuSettings::ControllerType::Handheld) {
        YuzuSettings::values.use_docked_mode.SetGlobal(!IsCustomConfig());
        YuzuSettings::values.use_docked_mode.SetValue(YuzuSettings::ConsoleMode::Handheld);
    }

    if (IsCustomConfig()) {
        EndGroup();
        return;
    }
    ReadTouchscreenValues();
    ReadMotionTouchValues();

    EndGroup();
}

void YuzuConfig::ReadMotionTouchValues() {
    YuzuSettings::values.touch_from_button_maps.clear();
    int num_touch_from_button_maps = BeginArray(std::string("touch_from_button_maps"));

    if (num_touch_from_button_maps > 0) {
        for (int i = 0; i < num_touch_from_button_maps; ++i) {
            SetArrayIndex(i);

            YuzuSettings::TouchFromButtonMap map;
            map.name = ReadStringSetting(std::string("name"), std::string("default"));

            const int num_touch_maps = BeginArray(std::string("entries"));
            map.buttons.reserve(num_touch_maps);
            for (int j = 0; j < num_touch_maps; j++) {
                SetArrayIndex(j);
                std::string touch_mapping = ReadStringSetting(std::string("bind"));
                map.buttons.emplace_back(std::move(touch_mapping));
            }
            EndArray(); // entries
            YuzuSettings::values.touch_from_button_maps.emplace_back(std::move(map));
        }
    } else {
        YuzuSettings::values.touch_from_button_maps.emplace_back(
            YuzuSettings::TouchFromButtonMap{"default", {}});
        num_touch_from_button_maps = 1;
    }
    EndArray(); // touch_from_button_maps

    YuzuSettings::values.touch_from_button_map_index = std::clamp(
        YuzuSettings::values.touch_from_button_map_index.GetValue(), 0, num_touch_from_button_maps - 1);
}

void YuzuConfig::ReadCoreValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Core));

    ReadCategory(YuzuSettings::Category::Core);

    EndGroup();
}

void YuzuConfig::ReadDataStorageValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::DataStorage));

    FS::SetYuzuPath(FS::YuzuPath::NANDDir, ReadStringSetting(std::string("nand_directory")));
    FS::SetYuzuPath(FS::YuzuPath::SDMCDir, ReadStringSetting(std::string("sdmc_directory")));
    FS::SetYuzuPath(FS::YuzuPath::LoadDir, ReadStringSetting(std::string("load_directory")));
    FS::SetYuzuPath(FS::YuzuPath::DumpDir, ReadStringSetting(std::string("dump_directory")));
    FS::SetYuzuPath(FS::YuzuPath::TASDir, ReadStringSetting(std::string("tas_directory")));

    ReadCategory(YuzuSettings::Category::DataStorage);

    EndGroup();
}

void YuzuConfig::ReadDebuggingValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Debugging));

    // Intentionally not using the QT default setting as this is intended to be changed in the ini
    YuzuSettings::values.record_frame_times =
        ReadBooleanSetting(std::string("record_frame_times"), std::make_optional(false));

    ReadCategory(YuzuSettings::Category::Debugging);
    ReadCategory(YuzuSettings::Category::DebuggingGraphics);

    EndGroup();
}

#ifdef __unix__
void YuzuConfig::ReadLinuxValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Linux));

    ReadCategory(YuzuSettings::Category::Linux);

    EndGroup();
}
#endif

void YuzuConfig::ReadServiceValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Services));

    ReadCategory(YuzuSettings::Category::Services);

    EndGroup();
}

void YuzuConfig::ReadDisabledAddOnValues() {
    // Custom config section
    BeginGroup(std::string("DisabledAddOns"));

    const int size = BeginArray(std::string(""));
    for (int i = 0; i < size; ++i) {
        SetArrayIndex(i);
        const auto title_id = ReadUnsignedIntegerSetting(std::string("title_id"), 0);
        std::vector<std::string> out;
        const int d_size = BeginArray("disabled");
        for (int j = 0; j < d_size; ++j) {
            SetArrayIndex(j);
            out.push_back(ReadStringSetting(std::string("d"), std::string("")));
        }
        EndArray(); // d
        YuzuSettings::values.disabled_addons.insert_or_assign(title_id, out);
    }
    EndArray(); // Base disabled addons array - Has no base key

    EndGroup();
}

void YuzuConfig::ReadMiscellaneousValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Miscellaneous));

    ReadCategory(YuzuSettings::Category::Miscellaneous);

    EndGroup();
}

void YuzuConfig::ReadCpuValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Cpu));

    ReadCategory(YuzuSettings::Category::Cpu);
    ReadCategory(YuzuSettings::Category::CpuDebug);
    ReadCategory(YuzuSettings::Category::CpuUnsafe);

    EndGroup();
}

void YuzuConfig::ReadRendererValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Renderer));

    ReadCategory(YuzuSettings::Category::Renderer);
    ReadCategory(YuzuSettings::Category::RendererAdvanced);
    ReadCategory(YuzuSettings::Category::RendererDebug);

    EndGroup();
}

void YuzuConfig::ReadScreenshotValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Screenshots));

    ReadCategory(YuzuSettings::Category::Screenshots);
    FS::SetYuzuPath(FS::YuzuPath::ScreenshotsDir,
                    ReadStringSetting(std::string("screenshot_path")));

    EndGroup();
}

void YuzuConfig::ReadSystemValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::System));

    ReadCategory(YuzuSettings::Category::System);
    ReadCategory(YuzuSettings::Category::SystemAudio);

    EndGroup();
}

void YuzuConfig::ReadWebServiceValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::WebService));

    ReadCategory(YuzuSettings::Category::WebService);

    EndGroup();
}

void YuzuConfig::ReadNetworkValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Services));

    ReadCategory(YuzuSettings::Category::Network);

    EndGroup();
}

void YuzuConfig::ReadLibraryAppletValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::LibraryApplet));

    ReadCategory(YuzuSettings::Category::LibraryApplet);

    EndGroup();
}

void YuzuConfig::ReadValues() {
    if (global) {
        ReadDataStorageValues();
        ReadDebuggingValues();
        ReadDisabledAddOnValues();
        ReadNetworkValues();
        ReadServiceValues();
        ReadWebServiceValues();
        ReadMiscellaneousValues();
        ReadLibraryAppletValues();
    }
    ReadControlValues();
    ReadCoreValues();
    ReadCpuValues();
#ifdef __unix__
    ReadLinuxValues();
#endif
    ReadRendererValues();
    ReadAudioValues();
    ReadSystemValues();
}

void YuzuConfig::SavePlayerValues(const std::size_t player_index) {
    std::string player_prefix;
    if (type != ConfigType::InputProfile) {
        player_prefix = std::string("player_").append(ToString(player_index)).append("_");
    }

    const auto& player = YuzuSettings::values.players.GetValue()[player_index];
    if (IsCustomConfig()) {
        if (player.profile_name.empty()) {
            // No custom profile selected
            return;
        }
        WriteStringSetting(std::string(player_prefix).append("profile_name"), player.profile_name,
                           std::make_optional(std::string("")));
    }

    WriteIntegerSetting(
        std::string(player_prefix).append("type"), static_cast<u8>(player.controller_type),
        std::make_optional(static_cast<u8>(YuzuSettings::ControllerType::ProController)));

    if (!player_prefix.empty() || !YuzuSettings::IsConfiguringGlobal()) {
        if (global) {
            const auto& player_global = YuzuSettings::values.players.GetValue(true)[player_index];
            WriteStringSetting(std::string(player_prefix).append("profile_name"),
                               player_global.profile_name, std::make_optional(std::string("")));
        }
        WriteBooleanSetting(std::string(player_prefix).append("connected"), player.connected,
                            std::make_optional(player_index == 0));
        WriteIntegerSetting(std::string(player_prefix).append("vibration_enabled"),
                            player.vibration_enabled, std::make_optional(true));
        WriteIntegerSetting(std::string(player_prefix).append("vibration_strength"),
                            player.vibration_strength, std::make_optional(100));
        WriteIntegerSetting(std::string(player_prefix).append("body_color_left"),
                            player.body_color_left,
                            std::make_optional(YuzuSettings::JOYCON_BODY_NEON_BLUE));
        WriteIntegerSetting(std::string(player_prefix).append("body_color_right"),
                            player.body_color_right,
                            std::make_optional(YuzuSettings::JOYCON_BODY_NEON_RED));
        WriteIntegerSetting(std::string(player_prefix).append("button_color_left"),
                            player.button_color_left,
                            std::make_optional(YuzuSettings::JOYCON_BUTTONS_NEON_BLUE));
        WriteIntegerSetting(std::string(player_prefix).append("button_color_right"),
                            player.button_color_right,
                            std::make_optional(YuzuSettings::JOYCON_BUTTONS_NEON_RED));
    }
}

void YuzuConfig::SaveTouchscreenValues() {
    const auto& touchscreen = YuzuSettings::values.touchscreen;

    WriteBooleanSetting(std::string("touchscreen_enabled"), touchscreen.enabled,
                        std::make_optional(true));

    WriteIntegerSetting(std::string("touchscreen_angle"), touchscreen.rotation_angle,
                        std::make_optional(static_cast<u32>(0)));
    WriteIntegerSetting(std::string("touchscreen_diameter_x"), touchscreen.diameter_x,
                        std::make_optional(static_cast<u32>(90)));
    WriteIntegerSetting(std::string("touchscreen_diameter_y"), touchscreen.diameter_y,
                        std::make_optional(static_cast<u32>(90)));
}

void YuzuConfig::SaveMotionTouchValues() {
    BeginArray(std::string("touch_from_button_maps"));
    for (std::size_t p = 0; p < YuzuSettings::values.touch_from_button_maps.size(); ++p) {
        SetArrayIndex(static_cast<int>(p));
        WriteStringSetting(std::string("name"), YuzuSettings::values.touch_from_button_maps[p].name,
                           std::make_optional(std::string("default")));

        BeginArray(std::string("entries"));
        for (std::size_t q = 0; q < YuzuSettings::values.touch_from_button_maps[p].buttons.size();
             ++q) {
            SetArrayIndex(static_cast<int>(q));
            WriteStringSetting(std::string("bind"),
                               YuzuSettings::values.touch_from_button_maps[p].buttons[q]);
        }
        EndArray(); // entries
    }
    EndArray(); // touch_from_button_maps
}

void YuzuConfig::SaveValues() {
    if (global) {
        LOG_DEBUG(Config, "Saving global generic configuration values");
        SaveDataStorageValues();
        SaveDebuggingValues();
        SaveDisabledAddOnValues();
        SaveNetworkValues();
        SaveWebServiceValues();
        SaveMiscellaneousValues();
        SaveLibraryAppletValues();
    } else {
        LOG_DEBUG(Config, "Saving only generic configuration values");
    }
    SaveControlValues();
    SaveCoreValues();
    SaveCpuValues();
#ifdef __unix__
    SaveLinuxValues();
#endif
    SaveRendererValues();
    SaveAudioValues();
    SaveSystemValues();

    WriteToIni();
}

void YuzuConfig::SaveAudioValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Audio));

    WriteCategory(YuzuSettings::Category::Audio);
    WriteCategory(YuzuSettings::Category::UiAudio);

    EndGroup();
}

void YuzuConfig::SaveControlValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Controls));

    WriteCategory(YuzuSettings::Category::Controls);

    YuzuSettings::values.players.SetGlobal(!IsCustomConfig());
    for (std::size_t p = 0; p < YuzuSettings::values.players.GetValue().size(); ++p) {
        SavePlayerValues(p);
    }
    if (IsCustomConfig()) {
        EndGroup();
        return;
    }
    SaveTouchscreenValues();
    SaveMotionTouchValues();

    EndGroup();
}

void YuzuConfig::SaveCoreValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Core));

    WriteCategory(YuzuSettings::Category::Core);

    EndGroup();
}

void YuzuConfig::SaveDataStorageValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::DataStorage));

    WriteStringSetting(std::string("nand_directory"), FS::GetYuzuPathString(FS::YuzuPath::NANDDir),
                       std::make_optional(FS::GetYuzuPathString(FS::YuzuPath::NANDDir)));
    WriteStringSetting(std::string("sdmc_directory"), FS::GetYuzuPathString(FS::YuzuPath::SDMCDir),
                       std::make_optional(FS::GetYuzuPathString(FS::YuzuPath::SDMCDir)));
    WriteStringSetting(std::string("load_directory"), FS::GetYuzuPathString(FS::YuzuPath::LoadDir),
                       std::make_optional(FS::GetYuzuPathString(FS::YuzuPath::LoadDir)));
    WriteStringSetting(std::string("dump_directory"), FS::GetYuzuPathString(FS::YuzuPath::DumpDir),
                       std::make_optional(FS::GetYuzuPathString(FS::YuzuPath::DumpDir)));
    WriteStringSetting(std::string("tas_directory"), FS::GetYuzuPathString(FS::YuzuPath::TASDir),
                       std::make_optional(FS::GetYuzuPathString(FS::YuzuPath::TASDir)));

    WriteCategory(YuzuSettings::Category::DataStorage);

    EndGroup();
}

void YuzuConfig::SaveDebuggingValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Debugging));

    // Intentionally not using the QT default setting as this is intended to be changed in the ini
    WriteBooleanSetting(std::string("record_frame_times"), YuzuSettings::values.record_frame_times);

    WriteCategory(YuzuSettings::Category::Debugging);
    WriteCategory(YuzuSettings::Category::DebuggingGraphics);

    EndGroup();
}

#ifdef __unix__
void YuzuConfig::SaveLinuxValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Linux));

    WriteCategory(YuzuSettings::Category::Linux);

    EndGroup();
}
#endif

void YuzuConfig::SaveNetworkValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Services));

    WriteCategory(YuzuSettings::Category::Network);

    EndGroup();
}

void YuzuConfig::SaveDisabledAddOnValues() {
    // Custom config section
    BeginGroup(std::string("DisabledAddOns"));

    int i = 0;
    BeginArray(std::string(""));
    for (const auto& elem : YuzuSettings::values.disabled_addons) {
        SetArrayIndex(i);
        WriteIntegerSetting(std::string("title_id"), elem.first,
                            std::make_optional(static_cast<u64>(0)));
        BeginArray(std::string("disabled"));
        for (std::size_t j = 0; j < elem.second.size(); ++j) {
            SetArrayIndex(static_cast<int>(j));
            WriteStringSetting(std::string("d"), elem.second[j],
                               std::make_optional(std::string("")));
        }
        EndArray(); // disabled
        ++i;
    }
    EndArray(); // Base disabled addons array - Has no base key

    EndGroup();
}

void YuzuConfig::SaveMiscellaneousValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Miscellaneous));

    WriteCategory(YuzuSettings::Category::Miscellaneous);

    EndGroup();
}

void YuzuConfig::SaveCpuValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Cpu));

    WriteCategory(YuzuSettings::Category::Cpu);
    WriteCategory(YuzuSettings::Category::CpuDebug);
    WriteCategory(YuzuSettings::Category::CpuUnsafe);

    EndGroup();
}

void YuzuConfig::SaveRendererValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Renderer));

    WriteCategory(YuzuSettings::Category::Renderer);
    WriteCategory(YuzuSettings::Category::RendererAdvanced);
    WriteCategory(YuzuSettings::Category::RendererDebug);

    EndGroup();
}

void YuzuConfig::SaveScreenshotValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::Screenshots));

    WriteStringSetting(std::string("screenshot_path"),
                       FS::GetYuzuPathString(FS::YuzuPath::ScreenshotsDir));
    WriteCategory(YuzuSettings::Category::Screenshots);

    EndGroup();
}

void YuzuConfig::SaveSystemValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::System));

    WriteCategory(YuzuSettings::Category::System);
    WriteCategory(YuzuSettings::Category::SystemAudio);

    EndGroup();
}

void YuzuConfig::SaveWebServiceValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::WebService));

    WriteCategory(YuzuSettings::Category::WebService);

    EndGroup();
}

void YuzuConfig::SaveLibraryAppletValues() {
    BeginGroup(YuzuSettings::TranslateCategory(YuzuSettings::Category::LibraryApplet));

    WriteCategory(YuzuSettings::Category::LibraryApplet);

    EndGroup();
}

bool YuzuConfig::ReadBooleanSetting(const std::string& key, const std::optional<bool> default_value) {
    std::string full_key = GetFullKey(key, false);
    if (!default_value.has_value()) {
        return config->GetBoolValue(GetSection().c_str(), full_key.c_str(), false);
    }

    if (config->GetBoolValue(GetSection().c_str(),
                             std::string(full_key).append("\\default").c_str(), false)) {
        return static_cast<bool>(default_value.value());
    } else {
        return config->GetBoolValue(GetSection().c_str(), full_key.c_str(),
                                    static_cast<bool>(default_value.value()));
    }
}

s64 YuzuConfig::ReadIntegerSetting(const std::string& key, const std::optional<s64> default_value) {
    std::string full_key = GetFullKey(key, false);
    if (!default_value.has_value()) {
        try {
            return std::stoll(
                std::string(config->GetValue(GetSection().c_str(), full_key.c_str(), "0")));
        } catch (...) {
            return 0;
        }
    }

    s64 result = 0;
    if (config->GetBoolValue(GetSection().c_str(),
                             std::string(full_key).append("\\default").c_str(), true)) {
        result = default_value.value();
    } else {
        try {
            result = std::stoll(std::string(config->GetValue(
                GetSection().c_str(), full_key.c_str(), ToString(default_value.value()).c_str())));
        } catch (...) {
            result = default_value.value();
        }
    }
    return result;
}

u64 YuzuConfig::ReadUnsignedIntegerSetting(const std::string& key,
                                       const std::optional<u64> default_value) {
    std::string full_key = GetFullKey(key, false);
    if (!default_value.has_value()) {
        try {
            return std::stoull(
                std::string(config->GetValue(GetSection().c_str(), full_key.c_str(), "0")));
        } catch (...) {
            return 0;
        }
    }

    u64 result = 0;
    if (config->GetBoolValue(GetSection().c_str(),
                             std::string(full_key).append("\\default").c_str(), true)) {
        result = default_value.value();
    } else {
        try {
            result = std::stoull(std::string(config->GetValue(
                GetSection().c_str(), full_key.c_str(), ToString(default_value.value()).c_str())));
        } catch (...) {
            result = default_value.value();
        }
    }
    return result;
}

double YuzuConfig::ReadDoubleSetting(const std::string& key,
                                 const std::optional<double> default_value) {
    std::string full_key = GetFullKey(key, false);
    if (!default_value.has_value()) {
        return config->GetDoubleValue(GetSection().c_str(), full_key.c_str(), 0);
    }

    double result;
    if (config->GetBoolValue(GetSection().c_str(),
                             std::string(full_key).append("\\default").c_str(), true)) {
        result = default_value.value();
    } else {
        result =
            config->GetDoubleValue(GetSection().c_str(), full_key.c_str(), default_value.value());
    }
    return result;
}

std::string YuzuConfig::ReadStringSetting(const std::string& key,
                                      const std::optional<std::string> default_value) {
    std::string result;
    std::string full_key = GetFullKey(key, false);
    if (!default_value.has_value()) {
        result = config->GetValue(GetSection().c_str(), full_key.c_str(), "");
        boost::replace_all(result, "\"", "");
        return result;
    }

    if (config->GetBoolValue(GetSection().c_str(),
                             std::string(full_key).append("\\default").c_str(), true)) {
        result = default_value.value();
    } else {
        result =
            config->GetValue(GetSection().c_str(), full_key.c_str(), default_value.value().c_str());
    }
    boost::replace_all(result, "\"", "");
    boost::replace_all(result, "//", "/");
    return result;
}

bool YuzuConfig::Exists(const std::string& section, const std::string& key) const {
    const std::string value = config->GetValue(section.c_str(), key.c_str(), "");
    return !value.empty();
}

void YuzuConfig::WriteBooleanSetting(const std::string& key, const bool& value,
                                 const std::optional<bool>& default_value,
                                 const std::optional<bool>& use_global) {
    std::optional<std::string> string_default = std::nullopt;
    if (default_value.has_value()) {
        string_default = std::make_optional(ToString(default_value.value()));
    }
    WritePreparedSetting(key, AdjustOutputString(ToString(value)), string_default, use_global);
}

void YuzuConfig::WriteDoubleSetting(const std::string& key, const double& value,
                                const std::optional<double>& default_value,
                                const std::optional<bool>& use_global) {
    std::optional<std::string> string_default = std::nullopt;
    if (default_value.has_value()) {
        string_default = std::make_optional(ToString(default_value.value()));
    }
    WritePreparedSetting(key, AdjustOutputString(ToString(value)), string_default, use_global);
}

void YuzuConfig::WriteStringSetting(const std::string& key, const std::string& value,
                                const std::optional<std::string>& default_value,
                                const std::optional<bool>& use_global) {
    std::optional string_default = default_value;
    if (default_value.has_value()) {
        string_default.value().append(AdjustOutputString(default_value.value()));
    }
    WritePreparedSetting(key, AdjustOutputString(value), string_default, use_global);
}

void YuzuConfig::WritePreparedSetting(const std::string& key, const std::string& adjusted_value,
                                  const std::optional<std::string>& adjusted_default_value,
                                  const std::optional<bool>& use_global) {
    std::string full_key = GetFullKey(key, false);
    if (adjusted_default_value.has_value() && use_global.has_value()) {
        if (!global) {
            WriteString(std::string(full_key).append("\\global"), ToString(use_global.value()));
        }
        if (global || use_global.value() == false) {
            WriteString(std::string(full_key).append("\\default"),
                        ToString(adjusted_default_value == adjusted_value));
            WriteString(full_key, adjusted_value);
        }
    } else if (adjusted_default_value.has_value() && !use_global.has_value()) {
        WriteString(std::string(full_key).append("\\default"),
                    ToString(adjusted_default_value == adjusted_value));
        WriteString(full_key, adjusted_value);
    } else {
        WriteString(full_key, adjusted_value);
    }
}

void YuzuConfig::WriteString(const std::string& key, const std::string& value) {
    config->SetValue(GetSection().c_str(), key.c_str(), value.c_str());
}

void YuzuConfig::Reload() {
    ReadValues();
    // To apply default value changes
    SaveValues();
}

void YuzuConfig::ClearControlPlayerValues() const {
    // Removes the entire [Controls] section
    const char* section = YuzuSettings::TranslateCategory(YuzuSettings::Category::Controls);
    config->Delete(section, nullptr, true);
}

const std::string& YuzuConfig::GetConfigFilePath() const {
    return config_loc;
}

void YuzuConfig::ReadCategory(const YuzuSettings::Category category) {
    const auto& settings = FindRelevantList(category);
    std::ranges::for_each(settings, [&](const auto& setting) { ReadSettingGeneric(setting); });
}

void YuzuConfig::WriteCategory(const YuzuSettings::Category category) {
    const auto& settings = FindRelevantList(category);
    std::ranges::for_each(settings, [&](const auto& setting) { WriteSettingGeneric(setting); });
}

void YuzuConfig::ReadSettingGeneric(YuzuSettings::BasicSetting* const setting) {
    if (!setting->Save() || (!setting->Switchable() && !global)) {
        return;
    }

    const std::string key = AdjustKey(setting->GetLabel());
    const std::string default_value(setting->DefaultToString());

    bool use_global = true;
    if (setting->Switchable() && !global) {
        use_global =
            ReadBooleanSetting(std::string(key).append("\\use_global"), std::make_optional(true));
        setting->SetGlobal(use_global);
    }

    if (global || !use_global) {
        const bool is_default =
            ReadBooleanSetting(std::string(key).append("\\default"), std::make_optional(true));
        if (!is_default) {
            const std::string setting_string = ReadStringSetting(key, default_value);
            setting->LoadString(setting_string);
        } else {
            // Empty string resets the Setting to default
            setting->LoadString("");
        }
    }
}

void YuzuConfig::WriteSettingGeneric(const YuzuSettings::BasicSetting* const setting) {
    if (!setting->Save()) {
        return;
    }

    std::string key = AdjustKey(setting->GetLabel());
    if (setting->Switchable()) {
        if (!global) {
            WriteBooleanSetting(std::string(key).append("\\use_global"), setting->UsingGlobal());
        }
        if (global || !setting->UsingGlobal()) {
            auto value = global ? setting->ToStringGlobal() : setting->ToString();
            WriteBooleanSetting(std::string(key).append("\\default"),
                                value == setting->DefaultToString());
            WriteStringSetting(key, value);
        }
    } else if (global) {
        WriteBooleanSetting(std::string(key).append("\\default"),
                            setting->ToString() == setting->DefaultToString());
        WriteStringSetting(key, setting->ToString());
    }
}

void YuzuConfig::BeginGroup(const std::string& group) {
    // You can't begin a group while reading/writing from a config array
    ASSERT(array_stack.empty());

    key_stack.push_back(AdjustKey(group));
}

void YuzuConfig::EndGroup() {
    // You can't end a group if you haven't started one yet
    ASSERT(!key_stack.empty());

    // You can't end a group when reading/writing from a config array
    ASSERT(array_stack.empty());

    key_stack.pop_back();
}

std::string YuzuConfig::GetSection() {
    if (key_stack.empty()) {
        return std::string{""};
    }

    return key_stack.front();
}

std::string YuzuConfig::GetGroup() const {
    if (key_stack.size() <= 1) {
        return std::string{""};
    }

    std::string key;
    for (size_t i = 1; i < key_stack.size(); ++i) {
        key.append(key_stack[i]).append("\\");
    }
    return key;
}

std::string YuzuConfig::AdjustKey(const std::string& key) {
    std::string adjusted_key(key);
    boost::replace_all(adjusted_key, "/", "\\");
    boost::replace_all(adjusted_key, " ", "%20");
    return adjusted_key;
}

std::string YuzuConfig::AdjustOutputString(const std::string& string) {
    std::string adjusted_string(string);
    boost::replace_all(adjusted_string, "\\", "/");

    // Windows requires that two forward slashes are used at the start of a path for unmapped
    // network drives so we have to watch for that here
#ifndef ANDROID
    if (string.substr(0, 2) == "//") {
        boost::replace_all(adjusted_string, "//", "/");
        adjusted_string.insert(0, "/");
    } else {
        boost::replace_all(adjusted_string, "//", "/");
    }
#endif

    // Needed for backwards compatibility with QSettings deserialization
    for (const auto& special_character : special_characters) {
        if (adjusted_string.find(special_character) != std::string::npos) {
            adjusted_string.insert(0, "\"");
            adjusted_string.append("\"");
            break;
        }
    }
    return adjusted_string;
}

std::string YuzuConfig::GetFullKey(const std::string& key, bool skipArrayIndex) {
    if (array_stack.empty()) {
        return std::string(GetGroup()).append(AdjustKey(key));
    }

    std::string array_key;
    for (size_t i = 0; i < array_stack.size(); ++i) {
        if (!array_stack[i].name.empty()) {
            array_key.append(array_stack[i].name).append("\\");
        }

        if (!skipArrayIndex || (array_stack.size() - 1 != i && array_stack.size() > 1)) {
            array_key.append(ToString(array_stack[i].index)).append("\\");
        }
    }
    std::string final_key = std::string(GetGroup()).append(array_key).append(AdjustKey(key));
    return final_key;
}

int YuzuConfig::BeginArray(const std::string& array) {
    array_stack.push_back(ConfigArray{AdjustKey(array), 0, 0});
    const int size = config->GetLongValue(GetSection().c_str(),
                                          GetFullKey(std::string("size"), true).c_str(), 0);
    array_stack.back().size = size;
    return size;
}

void YuzuConfig::EndArray() {
    // You can't end a config array before starting one
    ASSERT(!array_stack.empty());

    // Set the array size to 0 if the array is ended without changing the index
    int size = 0;
    if (array_stack.back().index != 0) {
        size = array_stack.back().size;
    }

    // Write out the size to config
    if (key_stack.size() == 1 && array_stack.back().name.empty()) {
        // Edge-case where the first array created doesn't have a name
        config->SetValue(GetSection().c_str(), std::string("size").c_str(), ToString(size).c_str());
    } else {
        const auto key = GetFullKey(std::string("size"), true);
        config->SetValue(GetSection().c_str(), key.c_str(), ToString(size).c_str());
    }

    array_stack.pop_back();
}

void YuzuConfig::SetArrayIndex(const int index) {
    // You can't set the array index if you haven't started one yet
    ASSERT(!array_stack.empty());

    const int array_index = index + 1;

    // You can't exceed the known max size of the array by more than 1
    ASSERT(array_stack.front().size + 1 >= array_index);

    // Change the config array size to the current index since you may want
    // to reduce the number of elements that you read back from the config
    // in the future.
    array_stack.back().size = array_index;
    array_stack.back().index = array_index;
}
