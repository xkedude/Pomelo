#import <spawn.h>
#import <dlfcn.h>
#import "utils.h"

#import <UIKit/UIKit.h>

#define JETSAM_PRIORITY_CRITICAL 19

#define MEMORYSTATUS_CMD_GET_PRIORITY_LIST            1
#define MEMORYSTATUS_CMD_SET_PRIORITY_PROPERTIES      2
#define MEMORYSTATUS_CMD_GET_JETSAM_SNAPSHOT          3
#define MEMORYSTATUS_CMD_GET_PRESSURE_STATUS          4
#define MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK   5    /* Set active memory limit = inactive memory limit, both non-fatal    */
#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT        6    /* Set active memory limit = inactive memory limit, both fatal    */
#define MEMORYSTATUS_CMD_SET_MEMLIMIT_PROPERTIES      7    /* Set memory limits plus attributes independently            */
#define MEMORYSTATUS_CMD_GET_MEMLIMIT_PROPERTIES      8    /* Get memory limits plus attributes                    */
#define MEMORYSTATUS_CMD_PRIVILEGED_LISTENER_ENABLE   9    /* Set the task's status as a privileged listener w.r.t memory notifications  */
#define MEMORYSTATUS_CMD_PRIVILEGED_LISTENER_DISABLE  10   /* Reset the task's status as a privileged listener w.r.t memory notifications  */
#define MEMORYSTATUS_CMD_AGGRESSIVE_JETSAM_LENIENT_MODE_ENABLE  11   /* Enable the 'lenient' mode for aggressive jetsam. See comments in kern_memorystatus.c near the top. */
#define MEMORYSTATUS_CMD_AGGRESSIVE_JETSAM_LENIENT_MODE_DISABLE 12   /* Disable the 'lenient' mode for aggressive jetsam. */
#define MEMORYSTATUS_CMD_GET_MEMLIMIT_EXCESS          13   /* Compute how much a process's phys_footprint exceeds inactive memory limit */
#define MEMORYSTATUS_CMD_ELEVATED_INACTIVEJETSAMPRIORITY_ENABLE         14 /* Set the inactive jetsam band for a process to JETSAM_PRIORITY_ELEVATED_INACTIVE */
#define MEMORYSTATUS_CMD_ELEVATED_INACTIVEJETSAMPRIORITY_DISABLE        15 /* Reset the inactive jetsam band for a process to the default band (0)*/
#define MEMORYSTATUS_CMD_SET_PROCESS_IS_MANAGED       16   /* (Re-)Set state on a process that marks it as (un-)managed by a system entity e.g. assertiond */
#define MEMORYSTATUS_CMD_GET_PROCESS_IS_MANAGED       17   /* Return the 'managed' status of a process */
#define MEMORYSTATUS_CMD_SET_PROCESS_IS_FREEZABLE     18   /* Is the process eligible for freezing? Apps and extensions can pass in FALSE to opt out of freezing, i.e.,
                                                        *  if they would prefer being jetsam'ed in the idle band to being frozen in an elevated band. */
#define MEMORYSTATUS_CMD_GET_PROCESS_IS_FREEZABLE     19   /* Return the freezable state of a process. */

typedef struct memorystatus_priority_properties {
    int32_t  priority;
    uint64_t user_data;
} memorystatus_priority_properties_t;

extern int memorystatus_get_level(user_addr_t level);
extern int memorystatus_control(uint32_t command, int32_t pid, uint32_t flags, void *buffer, size_t buffersize);

extern int proc_track_dirty(pid_t pid, uint32_t flags);

extern char** environ;

int tryEnableJIT(int argc, char **argv)
{
    int result = 0;
    if (getppid() != 1)
    {
        NSLog(@"parent pid is not launchd, calling ptrace(PT_TRACE_ME)");
        // Child process can call to PT_TRACE_ME
        // then both parent and child processes get CS_DEBUGGED
        result = ptrace(PT_TRACE_ME, 0, 0, 0);
        // FIXME: how to kill the child process?
        NSString *pidFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"pid.txt"];
        
        NSError *pidReadError;
        NSString *pidString = [NSString stringWithContentsOfFile:pidFilePath encoding:NSUTF8StringEncoding error:&pidReadError];
        
        if (pidString == nil) {
            NSLog(@"Error reading pid from pid.txt: %@", pidReadError);
            return 1;
        }
        
        // Convert the pid string to an integer
        pid_t me = [pidString intValue];
        
        int rc; memorystatus_priority_properties_t props = {JETSAM_PRIORITY_CRITICAL, 0};
        rc = memorystatus_control(MEMORYSTATUS_CMD_SET_PRIORITY_PROPERTIES, me, 0, &props, sizeof(props));
        if (rc < 0) { perror ("memorystatus_control"); NSLog(@"Error!");}
        rc = memorystatus_control(MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK, me, -1, NULL, 0);
        if (rc < 0) { perror ("memorystatus_control"); NSLog(@"Error!");}
        rc = memorystatus_control(MEMORYSTATUS_CMD_SET_PROCESS_IS_MANAGED, me, 0, NULL, 0);
        if (rc < 0) { perror ("memorystatus_control"); NSLog(@"Error!");}
        rc = memorystatus_control(MEMORYSTATUS_CMD_SET_PROCESS_IS_FREEZABLE, me, 0, NULL, 0);
        if (rc < 0) { perror ("memorystatus_control"); NSLog(@"Error!");}
        rc = proc_track_dirty(me, 0);
        if (rc != 0) { perror("proc_track_dirty");}
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *deleteError;
        if ([fileManager removeItemAtPath:pidFilePath error:&deleteError]) {
            NSLog(@"pid.txt deleted successfully");
        } else {
            NSLog(@"Error deleting pid.txt: %@", deleteError);
        }
        exit(0);
    }

    if (getEntitlementValue(@"com.apple.private.security.no-container")
    || getEntitlementValue(@"com.apple.private.security.container-required")
    || getEntitlementValue(@"com.apple.private.security.no-sandbox"))
    {
        NSLog(@"[+] Sandbox is disabled, trying to enable JIT");
        int pid;
        int ret = posix_spawnp(&pid, argv[0], NULL, NULL, argv, environ);
        if (ret == 0)
        {
            // posix_spawn is successful, let's check if JIT is enabled
            int retries;
            for (retries = 0; retries < 10; retries++)
            {
                usleep(10000);
                if (isJITEnabled())
                {
                    NSLog(@"[+] JIT has heen enabled with PT_TRACE_ME");
                    retries = -1;
                    result = 1;
                    break;
                }
            }
            if (retries != -1)
            {
                NSLog(@"[+] Failed to enable JIT: unknown reason");
                result = 0;
            }
        }
        else
        {
            NSLog(@"[+] Failed to enable JIT: posix_spawn() failed errno %d", errno);
            result = 0;
        }
    }
    else
    {
        result = -1;
    }
    return result;
}

__attribute__((constructor)) static void entry(int argc, char **argv)
{
    double systemVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    

    
    if (isJITEnabled()) {
        NSLog(@"yippee");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:@"JIT-NOT-ENABLED"];
        [defaults synchronize]; // Ensure the value is saved immediately
    } else {
        NSLog(@":(");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"JIT-NOT-ENABLED"];
        [defaults synchronize]; // Ensure the value is saved immediately
    }
    
    if (!getEntitlementValue(@"com.apple.developer.kernel.increased-memory-limit")) {
        NSLog(@"Entitlement Does Not Exist");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"entitlementNotExists"];
        [defaults synchronize]; // Ensure the value is saved immediately
        
        if (getEntitlementValue(@"com.apple.private.security.no-container")
            || getEntitlementValue(@"com.apple.private.security.container-required")
            || getEntitlementValue(@"com.apple.private.security.no-sandbox")) {
            pid_t me = getpid();
            
            // Create the file path in the app's Documents directory
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"pid.txt"];
            
            // Write the C code snippet to the file
            NSString *codeSnippet = [NSString stringWithFormat:@"%d", me];
            NSError *error;
            
            if (![codeSnippet writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                NSLog(@"Error writing code snippet to file: %@", error);
                exit(1);
            }
            tryEnableJIT(argc, argv);
        }
        
    }
    
    if (getEntitlementValue(@"com.apple.developer.kernel.increased-debugging-memory-limit")) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"increaseddebugmem"];
        [defaults synchronize]; // Ensure the value is saved immediately
    }
    if (getEntitlementValue(@"com.apple.developer.kernel.extended-virtual-addressing")) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"extended-virtual-addressing"];
        [defaults synchronize]; // Ensure the value is saved immediately
    }
        
}

