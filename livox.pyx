import cython
from libcpp cimport bool
from libc.stdint cimport int32_t

cdef extern from "Livox-SDK/sdk_core/include/livox_sdk.h":
    bool Init()
    void Uninit()
    bool Start()

def py_Init():
    return Init()

def py_Uninit():
    Uninit()

def py_Start():
    return Start()

cdef extern from "Livox-SDK/sdk_core/include/livox_def.h":
    int kMaxLidarCount = 32

    ctypedef enum DeviceType:
        kDeviceTypeHub = 0          # Livox Hub.
        kDeviceTypeLidarMid40 = 1   # Mid-40. 
        kDeviceTypeLidarTele = 2    # Tele. 
        kDeviceTypeLidarHorizon = 3 # Horizon. 
        kDeviceTypeLidarMid70 = 6   # Livox Mid-70. 
        kDeviceTypeLidarAvia = 7    # Avia. 

    ctypedef enum LidarState:
        kLidarStateInit = 0         # Initialization state.
        kLidarStateNormal = 1       # Normal work state.
        kLidarStatePowerSaving = 2  # Power-saving state.
        kLidarStateStandBy = 3      # Standby state.
        kLidarStateError = 4        # Error state.
        kLidarStateUnknown = 5      # Unknown state.

    ctypedef enum LidarMode:
        kLidarModeNormal = 1        # Normal mode.
        kLidarModePowerSaving = 2   # Power-saving mode.
        kLidarModeStandby = 3       # Standby mode.

    ctypedef enum LidarFeature:
        kLidarFeatureNone = 0       # No feature.
        kLidarFeatureRainFog = 1    # Rain and fog feature.

    ctypedef enum LidarIpMode:
        kLidarDynamicIpMode = 0     # Dynamic IP.
        kLidarStaticIpMode = 1      # Static IP.

    ctypedef enum LidarScanPattern:
        kNoneRepetitiveScanPattern = 0  # None Repetitive Scan Pattern.
        kRepetitiveScanPattern = 1      # Repetitive Scan Pattern.

    ctypedef enum LivoxStatus:
        kStatusSendFailed = -9           # Command send failed.
        kStatusHandlerImplNotExist = -8  # Handler implementation not exist.
        kStatusInvalidHandle = -7        # Device handle invalid.
        kStatusChannelNotExist = -6      # Command channel not exist.
        kStatusNotEnoughMemory = -5      # Not enough memory.
        kStatusTimeout = -4              # Operation timeout.
        kStatusNotSupported = -3         # Operation is not supported on this device.
        kStatusNotConnected = -2         # Requested device is not connected.
        kStatusFailure = -1              # Failure.
        kStatusSuccess = 0                # Success.

    ctypedef int32_t livox_status

    ctypedef enum DeviceEvent:
        kEventConnect = 0               # Device is connected.
        kEventDisconnect = 1            # Device is removed.
        kEventStateChange = 2           # Device working state changes or an error occurs.
        kEventHubConnectionChange = 3    # Hub is connected or LiDAR unit(s) is/are removed.

    ctypedef enum TimestampType:
        kTimestampTypeNoSync = 0    # No sync signal mode.
        kTimestampTypePtp = 1       # 1588v2.0 PTP sync mode.
        kTimestampTypeRsvd = 2      # Reserved use.
        kTimestampTypePpsGps = 3    # pps+gps sync mode.
        kTimestampTypePps = 4       # pps only sync mode.
        kTimestampTypeUnknown = 5    # Unknown mode.

    ctypedef enum PointDataType:
        kCartesian                # Cartesian coordinate point cloud.
        kSpherical                # Spherical coordinate point cloud.
        kExtendCartesian          # Extend cartesian coordinate point cloud.
        kExtendSpherical          # Extend spherical coordinate point cloud.
        kDualExtendCartesian      # Dual extend cartesian coordinate point cloud.
        kDualExtendSpherical      # Dual extend spherical coordinate point cloud.
        kImu                      # IMU data.
        kTripleExtendCartesian    # Triple extend cartesian coordinate point cloud.
        kTripleExtendSpherical    # Triple extend spherical coordinate point cloud.
        kMaxPointDataType        # Max Point Data Type.

    ctypedef enum PointCloudReturnMode:
        kFirstReturn              # First single return mode.
        kStrongestReturn          # Strongest single return mode.
        kDualReturn               # Dual return mode.
        kTripleReturn             # Triple return mode.

    ctypedef enum ImuFreq:
        kImuFreq0Hz              # IMU push closed.
        kImuFreq200Hz            # IMU push frequency 200Hz.

    int LIVOX_SDK_MAJOR_VERSION = 2
    int LIVOX_SDK_MINOR_VERSION = 3
    int LIVOX_SDK_PATCH_VERSION = 0

    int kBroadcastCodeSize = 16

    ctypedef packed struct LivoxSdkVersion:
        int major
        int minor 
        int patch

