// SPDX-FileCopyrightText: Copyright 2024 yuzu Emulator Project
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "common/settings.h"

static inline YuzuSettings::ScalingFilter GetScalingFilter() {
    return YuzuSettings::values.scaling_filter.GetValue();
}

static inline YuzuSettings::AntiAliasing GetAntiAliasing() {
    return YuzuSettings::values.anti_aliasing.GetValue();
}

static inline YuzuSettings::ScalingFilter GetScalingFilterForAppletCapture() {
    return YuzuSettings::ScalingFilter::Bilinear;
}

static inline YuzuSettings::AntiAliasing GetAntiAliasingForAppletCapture() {
    return YuzuSettings::AntiAliasing::None;
}

struct PresentFilters {
    YuzuSettings::ScalingFilter (*get_scaling_filter)();
    YuzuSettings::AntiAliasing (*get_anti_aliasing)();
};

constexpr PresentFilters PresentFiltersForDisplay{
    .get_scaling_filter = &GetScalingFilter,
    .get_anti_aliasing = &GetAntiAliasing,
};

constexpr PresentFilters PresentFiltersForAppletCapture{
    .get_scaling_filter = &GetScalingFilterForAppletCapture,
    .get_anti_aliasing = &GetAntiAliasingForAppletCapture,
};
