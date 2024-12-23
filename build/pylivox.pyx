import cython
from libcpp cimport bool
from libc.stdint cimport int32_t, int16_t, int8_t, int64_t, uint8_t, uint16_t, uint64_t, uint32_t
from cython.cimports.cpython import array
import array
from cython.operator import dereference
from cython.cimports.cpython.pystate import PyGILState_Ensure, PyGILState_Release, PyGILState_STATE
kMaxLidarCount = 32

LIVOX_SDK_MAJOR_VERSION = 2
LIVOX_SDK_MINOR_VERSION = 3
LIVOX_SDK_PATCH_VERSION = 0

kBroadcastCodeSize = 16

ctypedef int32_t livox_status

cdef extern from "../sdk_core/include/livox_sdk.h":
    bool Init() 
    void Uninit() 
    bool Start() 
    void DisableConsoleLogger() 
    void SaveLoggerFile() 
    void GetLivoxSdkVersion(LivoxSdkVersion* version) 
    ctypedef void (*CommonCommandCallback)(livox_status status, uint8_t handle, uint8_t response, void* client_data)
    livox_status HubStartSampling(CommonCommandCallback cb, void* client_data) 
    livox_status HubStopSampling(CommonCommandCallback cb, void *client_data) 
    uint8_t HubGetLidarHandle(uint8_t slot, uint8_t id) 
    livox_status DisconnectDevice(uint8_t handle, CommonCommandCallback cb, void *client_data) 
    livox_status SetCartesianCoordinate(uint8_t handle, CommonCommandCallback cb, void *client_data) 
    livox_status SetSphericalCoordinate(uint8_t handle, CommonCommandCallback cb, void *client_data) 
    livox_status AddHubToConnect(const char *broadcast_code, uint8_t *handle) 
    livox_status AddLidarToConnect(const char *broadcast_code, uint8_t *handle) 
    livox_status GetConnectedDevices(DeviceInfo *devices, uint8_t *size) 
    ctypedef void (*ErrorMessageCallback)(livox_status status, uint8_t handle, ErrorMessage *message)
    livox_status SetErrorMessageCallback(uint8_t handle, ErrorMessageCallback cb) 
    ctypedef void (*DataCallback)(uint8_t handle, LivoxEthPacket *data, uint32_t data_num, void* client_data)
    void SetDataCallback(uint8_t handle, DataCallback cb, void* client_data)
    livox_status LidarStartSampling(uint8_t handle, CommonCommandCallback cb, void* client_data) 
    livox_status LidarStopSampling(uint8_t handle, CommonCommandCallback cb, void* client_data) 
    ctypedef void (*LidarGetExtrinsicParameterCallback)(livox_status status, uint8_t handle, LidarGetExtrinsicParameterResponse *response, void *client_data)
    livox_status LidarGetExtrinsicParameter(uint8_t handle, LidarGetExtrinsicParameterCallback cb, void *client_data) 
    ctypedef void (*DeviceInformationCallback)(livox_status status, uint8_t handle, DeviceInformationResponse *response, void *client_data)
    livox_status QueryDeviceInformation(uint8_t handle, DeviceInformationCallback cb, void *client_data) 
    ctypedef void (*DeviceStateUpdateCallback)(const DeviceInfo *device, DeviceEvent type)
    void SetDeviceStateUpdateCallback(DeviceStateUpdateCallback cb) 
    ctypedef void (*DeviceBroadcastCallback)(const BroadcastDeviceInfo *info)
    void SetBroadcastCallback(DeviceBroadcastCallback cb) 

def PyInit():
    '''
    * Initialize the SDK.
    * @return true if successfully initialized, otherwise false.
    '''
    return Init()

def PyUninit():
    '''
    * Save the log file.
    '''
    Uninit()

def PyStart():
    '''
    * Start the device scanning routine which runs on a separate thread.
    * @return true if successfully started, otherwise false.
    '''
    return Start()

def PyDisableConsoleLogger():
    '''
    * Disable console log output.
    '''
    return DisableConsoleLogger()

def PySaveLoggerFile():
    '''
    * Save the log file.
    '''
    return SaveLoggerFile()

def PyGetLivoxSdkVersion(version: PyLivoxSdkVersion):
    '''
    * Return SDK's version information in a numeric form.
    * @param version Pointer to a version structure for returning the version information.
    '''
    GetLivoxSdkVersion(&version.core)

cdef void cCommonCommandCallback(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    global pyCommonCommandCallback
    pyCommonCommandCallback(status, handle, response, <object> client_data)

cdef void cHubStartSampling(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyHubStartSampling
        pyHubStartSampling(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)
 
def PyHubStartSampling(cb, client_data):
    '''
    * Start hub sampling.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyHubStartSampling
    pyHubStartSampling = cb
    return HubStartSampling(cHubStartSampling, <void*> client_data)

cdef void cHubStopSampling(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyHubStopSampling
        pyHubStopSampling(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)
 
def PyHubStopSampling(cb, client_data):
    '''
    * Stop the Livox Hub's sampling.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyHubStopSampling
    pyHubStopSampling = cb 
    return HubStopSampling(cHubStopSampling, <void*> client_data)

def PyHubGetLidarHandle(slot, id):
    '''
    * Get the LiDAR unit handle used in the Livox Hub data callback function from slot and id.
    * @param  slot   Livox Hub's slot.
    * @param  id     Livox Hub's id.
    * @return LiDAR unit handle.
    '''
    return HubGetLidarHandle(slot, id)

cdef void cDisconnectDevice(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyDisconnectDevice
        pyDisconnectDevice(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)
 
def PyDisconnectDevice(handle, cb, client_data):
    '''
    * Disconnect divice.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyDisconnectDevice
    pyDisconnectDevice = cb 
    return DisconnectDevice(handle, cDisconnectDevice, <void*> client_data)

cdef void cSetCartesianCoordinate(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pySetCartesianCoordinate
        pySetCartesianCoordinate(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)
 
def PySetCartesianCoordinate(handle, cb, client_data):
    '''
    * Change point cloud coordinate system to cartesian coordinate.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pySetCartesianCoordinate
    pySetCartesianCoordinate = cb 
    return SetCartesianCoordinate(handle, cSetCartesianCoordinate, <void*> client_data)

cdef void cSetSphericalCoordinate(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pySetSphericalCoordinate
        pySetSphericalCoordinate(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)
 
def PySetSphericalCoordinate(handle, cb, client_data):
    '''
    * Change point cloud coordinate system to spherical coordinate.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pySetSphericalCoordinate
    pySetSphericalCoordinate = cb 
    return SetSphericalCoordinate(handle, cSetSphericalCoordinate, <void*> client_data)

def PyAddHubToConnect(broadcast_code, handle):
    '''
    * Add a broadcast code to the connecting list and only devices with broadcast code in this list will be connected.      * The broadcast code is unique for every device.
    * @param broadcast_code device's broadcast code.
    * @param handle device handle. For Livox Hub, the handle is always 31; for LiDAR units connected to the Livox Hub,
    * the corresponding handle is (slot-1)*3+id-1.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    return AddHubToConnect(<char*> broadcast_code, <uint8_t*> handle)

def PyAddLidarToConnect(broadcast_code, handle):
    '''
    * Get all connected devices' information.
    * @param devices list of connected devices' information.
    * @param size    number of devices connected.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    cdef bytes encoded = broadcast_code.encode('utf-8')
    cdef uint8_t buffer = handle & 0xFF
    return AddLidarToConnect(encoded, &buffer), buffer

def PyGetConnectedDevices(devices, size):
    '''
    * Function type of callback that queries device's information.
    * @param status   kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    * error code.
    * @param handle   device handle.
    * @param response response from the device.
    * @param client_data user data associated with the command.
    '''
    return GetConnectedDevices(<DeviceInfo*> devices, <uint8_t*> size)

cdef void cErrorMessageCallback(livox_status status, uint8_t handle, ErrorMessage* message) noexcept:
    '''
    * Callback of the error status message.
    * kStatusSuccess on successful return, see \ref LivoxStatus for other
    * @param handle      device handle.
    * @param response    response from the device.
    '''
    global pyErrorMessageCallback
    py_message = PyErrorMessage()
    py_message.core = dereference(message)
    pyErrorMessageCallback(status, handle, py_message)

cdef void cSetErrorMessageCallback(livox_status status, uint8_t handle, ErrorMessage* message) noexcept:
    '''
    * Callback of the error status message.
    * kStatusSuccess on successful return, see \ref LivoxStatus for other
    * @param handle      device handle.
    * @param response    response from the device.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pySetErrorMessageCallback
        py_message = PyErrorMessage()
        py_message.core = dereference(message)
        pySetErrorMessageCallback(status, handle, py_message)
    finally:
        PyGILState_Release(state)


def PySetErrorMessageCallback(handle, cb):
    '''
    * Add error status callback for the device.
    * error code.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pySetErrorMessageCallback 
    pySetErrorMessageCallback = cb
    return SetErrorMessageCallback(handle, cSetErrorMessageCallback)

cdef void cDataCallback(uint8_t handle, LivoxEthPacket *data, uint32_t data_num, void* client_data) noexcept:
    '''
    * Callback function for receiving point cloud data.
    * @param handle      device handle.
    * @param data        device's data.
    * @param data_num    number of points in data.
    * @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyDataCallback
        py_data = PyLivoxEthPacket()
        py_data.core = dereference(data)
        pyDataCallback(handle, py_data, data_num, <object> client_data)
    finally:
        PyGILState_Release(state)

cdef void cSetDataCallback(uint8_t handle, LivoxEthPacket *data, uint32_t data_num, void* client_data) noexcept:
    '''
    * Callback function for receiving point cloud data.
    * @param handle      device handle.
    * @param data        device's data.
    * @param data_num    number of points in data.
    * @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pySetDataCallback
        py_data = PyLivoxEthPacket()
        py_data.core = dereference(data)
        pySetDataCallback(handle, py_data, data_num, <object> client_data)
    finally:
        PyGILState_Release(state)

def PySetDataCallback(handle, cb, client_data):
    '''
    * Set the callback to receive point cloud data. Only one callback is supported for a specific device. Set the point
    * cloud data callback before beginning sampling.
    * @param handle      device handle.
    * @param cb callback to receive point cloud data.
    * @note 1: Don't do any blocking operations in callback function, it will affects further data's receiving;
    * 2: For different device handle, callback to receive point cloud data will run on its own thread. If you bind
    * different handle to same callback function, please make sure that operations in callback function are thread-safe;
    * 3: callback function's data pointer will be invalid after callback fuction returns. It's recommended to
    * copy all data_num of point cloud every time callback is triggered.
    * @param client_data user data associated with the command.
    '''
    global pySetDataCallback
    pySetDataCallback = cb
    return SetDataCallback(handle, cSetDataCallback, <void*> client_data)

cdef void cLidarStartSampling(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyLidarStartSampling
        pyLidarStartSampling(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)

def PyLidarStartSampling(handle, cb, client_data):
    '''
    * Start LiDAR sampling.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyLidarStartSampling
    pyLidarStartSampling = cb
    return LidarStartSampling(handle, cLidarStartSampling, <void*> client_data)

cdef void cLidarStopSampling(livox_status status, uint8_t handle, uint8_t response, void* client_data) noexcept:
    '''
    Function type of callback with 1 byte of response.
    @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    error code.
    @param handle      device handle.
    @param response    response from the device.
    @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyLidarStopSampling
        pyLidarStopSampling(status, handle, response, <object> client_data)
    finally:
        PyGILState_Release(state)

def PyLidarStopSampling(handle, cb, client_data):
    '''
    * Stop LiDAR sampling.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyLidarStopSampling
    pyLidarStopSampling = cb
    return LidarStopSampling(handle, cLidarStopSampling, <void*> client_data)

cdef void cLidarGetExtrinsicParameterCallback(livox_status status, uint8_t handle, 
                                              LidarGetExtrinsicParameterResponse *response, void *client_data) noexcept:
    '''
    * @c LidarGetExtrinsicParameter response callback function.
    * @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    * error code.
    * @param handle      device handle.
    * @param response    response from the device.
    * @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyLidarGetExtrinsicParameterCallback
        py_response = PyLidarGetExtrinsicParameterResponse()
        py_response.core = dereference(response)
        pyLidarGetExtrinsicParameterCallback(status, handle, py_response, <object> client_data)
    finally:
        PyGILState_Release(state)

cdef void cLidarGetExtrinsicParameter(livox_status status, uint8_t handle, 
                                              LidarGetExtrinsicParameterResponse *response, void *client_data) noexcept:
    '''
    * @c LidarGetExtrinsicParameter response callback function.
    * @param status      kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    * error code.
    * @param handle      device handle.
    * @param response    response from the device.
    * @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyLidarGetExtrinsicParameter
        py_response = PyLidarGetExtrinsicParameterResponse()
        py_response.core = dereference(response)
        pyLidarGetExtrinsicParameter(status, handle, py_response, <object> client_data)
    finally:
        PyGILState_Release(state)


def PyLidarGetExtrinsicParameter(handle, cb, client_data):
    '''
    * Get LiDAR extrinsic parameters.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyLidarGetExtrinsicParameter
    pyLidarGetExtrinsicParameter = cb
    return LidarGetExtrinsicParameter(handle, cLidarGetExtrinsicParameter, <void*> client_data)

cdef void cDeviceInformationCallback(livox_status status, uint8_t handle, 
                                DeviceInformationResponse *response, void *client_data) noexcept:
    '''
    * Function type of callback that queries device's information.
    * @param status   kStatusSuccess on successful return, kStatusTimeout on timeout, see \ref LivoxStatus for other
    * error code.
    * @param handle   device handle.
    * @param response response from the device.
    * @param client_data user data associated with the command.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyDeviceInformationCallback
        py_response = PyDeviceInformationResponse()
        py_response.core = dereference(response)
        pyDeviceInformationCallback(status, handle, py_response, <object> client_data)
    finally:
        PyGILState_Release(state)

def PyQueryDeviceInformation(handle, cb, client_data):
    '''
    * Command to query device's information.
    * @param  handle        device handle.
    * @param  cb            callback for the command.
    * @param  client_data   user data associated with the command.
    * @return kStatusSuccess on successful return, see \ref LivoxStatus for other error code.
    '''
    global pyDeviceInformationCallback
    pyDeviceInformationCallback = cb
    return QueryDeviceInformation(handle, cDeviceInformationCallback, <void*> client_data)

cdef void cDeviceStateUpdateCallback(const DeviceInfo *device, DeviceEvent type) noexcept:
    '''
    * @c SetDeviceStateUpdateCallback response callback function.
    * @param device  information of the connected device.
    * @param type    the update type that indicates connection/disconnection of the device or change of working state.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyDeviceStateUpdateCallback
        py_device = PyDeviceInfo()
        py_device.core = dereference(device)
        pyDeviceStateUpdateCallback(py_device, type)
    finally:
        PyGILState_Release(state)

def PySetDeviceStateUpdateCallback(cb):
    '''
    * @brief Add a callback for device connection or working state changing event.
    * @note Livox SDK supports two hardware connection modes. 1: Directly connecting to the LiDAR device; 2. Connecting to
    * the LiDAR device(s) via the Livox Hub. In the first mode, connection/disconnection of every LiDAR unit is reported by
    * this callback. In the second mode, only connection/disconnection of the Livox Hub is reported by this callback. If
    * you want to get information of the LiDAR unit(s) connected to hub, see \ref HubQueryLidarInformation.
    * @note 3 conditions can trigger this callback:
    *         1. Connection and disconnection of device.
    *         2. A change of device working state.
    *         3. An error occurs.
    * @param cb callback for device connection/disconnection.
    '''
    global pyDeviceStateUpdateCallback
    pyDeviceStateUpdateCallback = cb
    return SetDeviceStateUpdateCallback(cDeviceStateUpdateCallback)

cdef void cDeviceBroadcastCallback(const BroadcastDeviceInfo *info) noexcept:
    '''
    * @c SetBroadcastCallback response callback function.
    * @param info information of the broadcast device, becomes invalid after the function returns.
    '''
    cdef PyGILState_STATE state = PyGILState_Ensure()
    try:
        global pyDeviceBroadcastCallback
        py_info = PyBroadcastDeviceInfo()
        py_info.core = dereference(info)
        pyDeviceBroadcastCallback(py_info)
    finally:
        PyGILState_Release(state)

def PySetBroadcastCallback(cb):
    global pyDeviceBroadcastCallback
    pyDeviceBroadcastCallback = cb
    SetBroadcastCallback(cDeviceBroadcastCallback)

cdef extern from "../sdk_core/include/livox_def.h":

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

    ctypedef packed struct LivoxSdkVersion:
        int major  # major number
        int minor  # minor number
        int patch  # patch number

    ctypedef packed struct LivoxRawPoint:
        int32_t x            # X axis, Unit:mm
        int32_t y            # Y axis, Unit:mm
        int32_t z            # Z axis, Unit:mm
        uint8_t reflectivity  # Reflectivity

    ctypedef packed struct LivoxSpherPoint:
        uint32_t depth       # Depth, Unit: mm
        uint16_t theta       # Zenith angle[0, 18000], Unit: 0.01 degree
        uint16_t phi         # Azimuth[0, 36000], Unit: 0.01 degree
        uint8_t reflectivity  # Reflectivity

    ctypedef packed struct LivoxPoint:
        float x               # X axis, Unit:m
        float y               # Y axis, Unit:m
        float z               # Z axis, Unit:m
        uint8_t reflectivity   # Reflectivity

    ctypedef packed struct LivoxExtendRawPoint:
        int32_t x             # X axis, Unit:mm
        int32_t y             # Y axis, Unit:mm
        int32_t z             # Z axis, Unit:mm
        uint8_t reflectivity   # Reflectivity
        uint8_t tag           # Tag

    ctypedef packed struct LivoxExtendSpherPoint:
        uint32_t depth        # Depth, Unit: mm
        uint16_t theta        # Zenith angle[0, 18000], Unit: 0.01 degree
        uint16_t phi          # Azimuth[0, 36000], Unit: 0.01 degree
        uint8_t reflectivity   # Reflectivity
        uint8_t tag           # Tag

    ctypedef packed struct LivoxDualExtendRawPoint:
        int32_t x1            # X axis, Unit:mm
        int32_t y1            # Y axis, Unit:mm
        int32_t z1            # Z axis, Unit:mm
        uint8_t reflectivity1  # Reflectivity
        uint8_t tag1          # Tag
        int32_t x2            # X axis, Unit:mm
        int32_t y2            # Y axis, Unit:mm
        int32_t z2            # Z axis, Unit:mm
        uint8_t reflectivity2  # Reflectivity
        uint8_t tag2          # Tag

    ctypedef packed struct LivoxDualExtendSpherPoint:
        uint16_t theta        # Zenith angle[0, 18000], Unit: 0.01 degree
        uint16_t phi          # Azimuth[0, 36000], Unit: 0.01 degree
        uint32_t depth1       # Depth, Unit: mm
        uint8_t reflectivity1  # Reflectivity
        uint8_t tag1          # Tag
        uint32_t depth2       # Depth, Unit: mm
        uint8_t reflectivity2  # Reflectivity
        uint8_t tag2          # Tag

    ctypedef packed struct LivoxTripleExtendRawPoint:
        int32_t x1            # X axis, Unit:mm
        int32_t y1            # Y axis, Unit:mm
        int32_t z1            # Z axis, Unit:mm
        uint8_t reflectivity1  # Reflectivity
        uint8_t tag1          # Tag
        int32_t x2            # X axis, Unit:mm
        int32_t y2            # Y axis, Unit:mm
        int32_t z2            # Z axis, Unit:mm
        uint8_t reflectivity2  # Reflectivity
        uint8_t tag2          # Tag
        int32_t x3            # X axis, Unit:mm
        int32_t y3            # Y axis, Unit:mm
        int32_t z3            # Z axis, Unit:mm
        uint8_t reflectivity3  # Reflectivity
        uint8_t tag3          # Tag

    ctypedef packed struct LivoxTripleExtendSpherPoint:
        uint16_t theta        # Zenith angle[0, 18000], Unit: 0.01 degree
        uint16_t phi          # Azimuth[0, 36000], Unit: 0.01 degree
        uint32_t depth1       # Depth, Unit: mm
        uint8_t reflectivity1  # Reflectivity
        uint8_t tag1          # Tag
        uint32_t depth2       # Depth, Unit: mm
        uint8_t reflectivity2  # Reflectivity
        uint8_t tag2          # Tag
        uint32_t depth3       # Depth, Unit: mm
        uint8_t reflectivity3  # Reflectivity
        uint8_t tag3          # Tag

    ctypedef packed struct LivoxImuPoint:
        float gyro_x          # Gyroscope X axis, Unit:rad/s
        float gyro_y          # Gyroscope Y axis, Unit:rad/s
        float gyro_z          # Gyroscope Z axis, Unit:rad/s
        float acc_x           # Accelerometer X axis, Unit:g
        float acc_y           # Accelerometer Y axis, Unit:g
        float acc_z           # Accelerometer Z axis, Unit:g

    ctypedef packed struct LidarErrorCode:
        uint32_t temp_status  # 0: Temperature in Normal State. 1: High or Low. 2: Extremely High or Extremely Low.
        uint32_t volt_status # 0: Voltage in Normal State. 1: High. 2: Extremely High.
        uint32_t motor_status  # 0: Motor in Normal State. 1: Motor in Warning State. 2: Motor in Error State, Unable to Work.
        uint32_t dirty_warn  # 0: Not Dirty or Blocked. 1: Dirty or Blocked.
        uint32_t firmware_err  # 0: Firmware is OK. 1: Firmware is Abnormal, Need to be Upgraded.
        uint32_t pps_status  # 0: No PPS Signal. 1: PPS Signal is OK.
        uint32_t device_status  # 0: Normal. 1: Warning for Approaching the End of Service Life.
        uint32_t fan_status  # 0: Fan in Normal State. 1: Fan in Warning State.
        uint32_t self_heating  # 0: Normal. 1: Low Temperature Self Heating On.
        uint32_t ptp_status  # 0: No 1588 Signal. 1: 1588 Signal is OK.
        uint32_t time_sync_status  # 0: System does not start time synchronization.
        uint32_t rsvd  # Reserved.
        uint32_t system_status  # 0: Normal. 1: Warning. 2: Error.

    ctypedef packed struct HubErrorCode:
        uint32_t sync_status  # 0: No synchronization signal. 1: 1588 synchronization.
        uint32_t temp_status  # 0: Temperature in Normal State. 1: High or Low. 2: Extremely High or Extremely Low.
        uint32_t lidar_status  # 0: LiDAR State is Normal. 1: LiDAR State is Abnormal.
        uint32_t lidar_link_status  # 0: LiDAR Connection is Normal. 1: LiDAR Connection is Abnormal.
        uint32_t firmware_err  # 0: LiDAR Firmware is OK. 1: LiDAR Firmware is Abnormal, Need to be Upgraded.
        uint32_t rsvd  # Reserved.
        uint32_t system_status  # 0: Normal. 1: Warning. 2: Error.

    ctypedef union ErrorMessage:
        uint32_t error_code  # Error code.
        LidarErrorCode lidar_error_code  # Lidar error code.
        HubErrorCode hub_error_code  # Hub error code.
        
    ctypedef packed struct LivoxEthPacket:
        uint8_t version  # Packet protocol version.
        uint8_t slot  # Slot number used for connecting LiDAR.
        uint8_t id  # LiDAR id.
        uint8_t rsvd  # Reserved.
        uint32_t err_code  # Device error status indicator information.
        uint8_t timestamp_type  # Timestamp type.
        uint8_t data_type  # Point cloud coordinate format, refer to PointDataType.
        uint8_t timestamp[8]  # Nanosecond or UTC format timestamp.
        uint8_t data[1]  # Point cloud data.

    ctypedef union StatusUnion:
        uint32_t progress  # LiDAR work state switching progress.
        ErrorMessage status_code  # LiDAR work state status code.

    ctypedef packed struct DeviceInfo:
        char broadcast_code[15]  # Device broadcast code, null-terminated string, 15 characters at most.
        uint8_t handle  # Device handle.
        uint8_t slot  # Slot number used for connecting LiDAR.
        uint8_t id  # LiDAR id.
        uint8_t type  # Device type, refer to DeviceType.
        uint16_t data_port  # Point cloud data UDP port.
        uint16_t cmd_port  # Control command UDP port.
        uint16_t sensor_port  # IMU data UDP port.
        char ip[16]  # IP address.
        LidarState state  # LiDAR state.
        LidarFeature feature  # LiDAR feature.
        StatusUnion status  # LiDAR work state status.
        uint8_t firmware_version[4]  # Firmware version.

    ctypedef packed struct BroadcastDeviceInfo:
        char broadcast_code[15]  # Device broadcast code, null-terminated string, 15 characters at most.
        uint8_t dev_type  # Device type, refer to DeviceType.
        uint16_t reserved  # Reserved.
        char ip[16]  # Device IP.       

    ctypedef packed struct ConnectedLidarInfo:
        char broadcast_code[15] # Device broadcast code, null-terminated string, 15 characters at most. 
        uint8_t dev_type                         # Device type, refer to \ref DeviceType. 
        uint8_t version[4]                       # Firmware version. 
        uint8_t slot                             # Slot number used for connecting LiDAR units. 
        uint8_t id                               # Device id.

    ctypedef packed struct LidarModeRequestItem:
        char broadcast_code[15] # Device broadcast code, null-terminated string, 15 characters at most.
        uint8_t state # LiDAR state, refer to \ref LidarMode. 

    ctypedef packed struct ReturnCode:
        uint8_t ret_code # Return code.
        char broadcast_code[15] # Device broadcast code.

    ctypedef packed struct DeviceBroadcastCode:
        char broadcast_code[15] # Device broadcast code.

    ctypedef packed struct RainFogSuppressRequestItem:
        char broadcast_code[15] # Device broadcast code.
        uint8_t feature # Close or open the rain and fog feature.

    ctypedef packed struct LidarGetExtrinsicParameterResponse:
        uint8_t ret_code
        float roll  # Roll angle, unit: degree.
        float pitch # Pitch angle, unit: degree.
        float yaw   # Yaw angle, unit: degree.
        int32_t x   # X translation, unit: mm.
        int32_t y   # Y translation, unit: mm.
        int32_t z   # Z translation, unit: mm.

    ctypedef packed struct DeviceInformationResponse:
        uint8_t ret_code    # Return code.
        uint8_t firmware_version[4] #Firmware version.

cdef class PyDeviceType:
    '''
    Device type.
    '''
    @staticmethod
    def DeviceTypeHub():
        return DeviceType.kDeviceTypeHub

    @staticmethod
    def DeviceTypeLidarMid40():
        return DeviceType.kDeviceTypeLidarMid40

    @staticmethod
    def DeviceTypeLidarTele():
        return DeviceType.kDeviceTypeLidarTele

    @staticmethod
    def DeviceTypeLidarHorizon():
        return DeviceType.kDeviceTypeLidarHorizon

    @staticmethod
    def DeviceTypeLidarMid70():
        return DeviceType.kDeviceTypeLidarMid70

    @staticmethod
    def DeviceTypeLidarAvia():
        return DeviceType.kDeviceTypeLidarAvia

cdef class PyLidarState:
    '''
    Lidar state.
    '''
    @staticmethod
    def LidarStateInit():
        return LidarState.kLidarStateInit

    @staticmethod
    def LidarStateNormal():
        return LidarState.kLidarStateNormal

    @staticmethod
    def LidarStatePowerSaving():
        return LidarState.kLidarStatePowerSaving

    @staticmethod
    def LidarStateStandBy():
        return LidarState.kLidarStateStandBy

    @staticmethod
    def LidarStateError():
        return LidarState.kLidarStateError

    @staticmethod
    def LidarStateUnknown():
        return LidarState.kLidarStateUnknown


cdef class PyLidarMode:
    '''
    Lidar mode.
    '''
    @staticmethod
    def LidarModeNormal():
        return LidarMode.kLidarModeNormal

    @staticmethod
    def LidarModePowerSaving():
        return LidarMode.kLidarModePowerSaving

    @staticmethod
    def LidarModeStandby():
        return LidarMode.kLidarModeStandby

cdef class PyLidarFeature:
    '''
    Lidar feature.
    '''
    @staticmethod
    def LidarFeatureNone():
        return LidarFeature.kLidarFeatureNone

    @staticmethod
    def LidarFeatureRainFog():
        return LidarFeature.kLidarFeatureRainFog

cdef class PyLidarIpMode:
    '''
    Lidar IP mode.
    '''
    @staticmethod
    def LidarDynamicIpMode():
        return LidarIpMode.kLidarDynamicIpMode

    @staticmethod
    def LidarStaticIpMode():
        return LidarIpMode.kLidarStaticIpMode

cdef class PyLidarScanPattern:
    '''
    Lidar Scan Pattern.
    '''
    @staticmethod
    def NoneRepetitiveScanPattern():
        return LidarScanPattern.kNoneRepetitiveScanPattern

    @staticmethod
    def RepetitiveScanPattern():
        return LidarScanPattern.kRepetitiveScanPattern

cdef class PyLivoxStatus:
    '''
    Function return value definition.
    '''
    @staticmethod
    def StatusSendFailed():
        return LivoxStatus.kStatusSendFailed

    @staticmethod
    def StatusHandlerImplNotExist():
        return LivoxStatus.kStatusHandlerImplNotExist

    @staticmethod
    def StatusInvalidHandle():
        return LivoxStatus.kStatusInvalidHandle

    @staticmethod
    def StatusChannelNotExist():
        return LivoxStatus.kStatusChannelNotExist

    @staticmethod
    def StatusNotEnoughMemory():
        return LivoxStatus.kStatusNotEnoughMemory

    @staticmethod
    def StatusTimeout():
        return LivoxStatus.kStatusTimeout

    @staticmethod
    def StatusNotSupported():
        return LivoxStatus.kStatusNotSupported

    @staticmethod
    def StatusNotConnected():
        return LivoxStatus.kStatusNotConnected

    @staticmethod
    def StatusFailure():
        return LivoxStatus.kStatusFailure

    @staticmethod
    def StatusSuccess():
        return LivoxStatus.kStatusSuccess

cdef class PyDeviceEvent:
    '''
    Device update type, indicating the change of device connection or working state.
    '''
    @staticmethod
    def EventConnect():
        return DeviceEvent.kEventConnect

    @staticmethod
    def EventDisconnect():
        return DeviceEvent.kEventDisconnect

    @staticmethod
    def EventStateChange():
        return DeviceEvent.kEventStateChange

    @staticmethod
    def EventHubConnectionChange():
        return DeviceEvent.kEventHubConnectionChange

cdef class PyTimestampType:
    '''
    Timestamp sync mode define.
    '''
    @staticmethod
    def TimestampTypeNoSync():
        return TimestampType.kTimestampTypeNoSync

    @staticmethod
    def TimestampTypePtp():
        return TimestampType.kTimestampTypePtp

    @staticmethod
    def TimestampTypeRsvd():
        return TimestampType.kTimestampTypeRsvd

    @staticmethod
    def TimestampTypePpsGps():
        return TimestampType.kTimestampTypePpsGps

    @staticmethod
    def TimestampTypePps():
        return TimestampType.kTimestampTypePps

    @staticmethod
    def TimestampTypeUnknown():
        return TimestampType.kTimestampTypeUnknown

cdef class PyPointDataType:
    '''
    Point data type.
    '''
    @staticmethod
    def PointDataTypeCartesian():
        return PointDataType.kCartesian

    @staticmethod
    def PointDataTypeSpherical():
        return PointDataType.kSpherical

    @staticmethod
    def PointDataTypeExtendCartesian():
        return PointDataType.kExtendCartesian

    @staticmethod
    def PointDataTypeExtendSpherical():
        return PointDataType.kExtendSpherical

    @staticmethod
    def PointDataTypeDualExtendCartesian():
        return PointDataType.kDualExtendCartesian

    @staticmethod
    def PointDataTypeDualExtendSpherical():
        return PointDataType.kDualExtendSpherical

    @staticmethod
    def PointDataTypeImu():
        return PointDataType.kImu

    @staticmethod
    def PointDataTypeTripleExtendCartesian():
        return PointDataType.kTripleExtendCartesian

    @staticmethod
    def PointDataTypeTripleExtendSpherical():
        return PointDataType.kTripleExtendSpherical

    @staticmethod
    def PointDataTypeMax():
        return PointDataType.kMaxPointDataType

cdef class PyPointCloudReturnMode:
    '''
    Point cloud return mode.
    '''
    @staticmethod
    def PointCloudReturnFirst():
        return PointCloudReturnMode.kFirstReturn

    @staticmethod
    def PointCloudReturnStrongest():
        return PointCloudReturnMode.kStrongestReturn

    @staticmethod
    def PointCloudReturnDual():
        return PointCloudReturnMode.kDualReturn

    @staticmethod
    def PointCloudReturnTriple():
        return PointCloudReturnMode.kTripleReturn

cdef class PyImuFreq:
    '''
    IMU push frequency.
    '''
    @staticmethod
    def ImuFreq0Hz():
        return ImuFreq.kImuFreq0Hz

    @staticmethod
    def ImuFreq200Hz():
        return ImuFreq.kImuFreq200Hz

cdef class PyLivoxSdkVersion:
    '''
    The numeric version information struct.
    '''
    cdef LivoxSdkVersion core

    def __init__(self, int major=0, int minor=0, int patch=0):
        self.core = LivoxSdkVersion(major, minor, patch)

    @property
    def major(self):
        return self.core.major

    @major.setter
    def major(self, major):
        self.core.major = major

    @property
    def minor(self):
        return self.core.minor
    
    @minor.setter
    def minor(self, minor):
        self.core.minor = minor

    @property
    def patch(self):
        return self.core.patch

    @patch.setter
    def patch(self, patch):
        self.core.patch = patch

cdef class PyLivoxRawPoint:
    '''
    Cartesian coordinate format.
    '''
    cdef LivoxRawPoint core

    def __init__(self, int x=0, int y=0, int z=0, int reflectivity=0):
        self.core = LivoxRawPoint(x, y, z, reflectivity)

    @property
    def x(self):
        return self.core.x

    @x.setter
    def x(self, x):
        self.core.x = x

    @property
    def y(self):
        return self.core.y

    @y.setter
    def y(self, y):
        self.core.y = y

    @property
    def z(self):
        return self.core.z

    @z.setter
    def z(self, z):
        self.core.z = z

    @property
    def reflectivity(self):
        return self.core.reflectivity

    @reflectivity.setter
    def reflectivity(self, reflectivity):
        self.core.reflectivity = reflectivity

cdef class PyLivoxSpherPoint:
    '''
    Spherical coordinate format.
    '''
    cdef LivoxSpherPoint core

    def __init__(self, uint32_t depth=0, uint16_t theta=0, uint16_t phi=0, uint8_t reflectivity=0):
        self.core = LivoxSpherPoint(depth, theta, phi, reflectivity)

    @property
    def depth(self):
        return self.core.depth

    @depth.setter
    def depth(self, depth):
        self.core.depth = depth

    @property
    def theta(self):
        return self.core.theta

    @theta.setter
    def theta(self, theta):
        self.core.theta = theta

    @property
    def phi(self):
        return self.core.phi

    @phi.setter
    def phi(self, phi):
        self.core.phi = phi

    @property
    def reflectivity(self):
        return self.core.reflectivity

    @reflectivity.setter
    def reflectivity(self, reflectivity):
        self.core.reflectivity = reflectivity

cdef class PyLivoxPoint:
    '''
    Standard point cloud format.
    '''
    cdef LivoxPoint core  # Correctly define core as a C struct

    def __init__(self, float x=0, float y=0, float z=0, uint8_t reflectivity=0):
        self.core = LivoxPoint(x, y, z, reflectivity)

    @property
    def x(self):
        return self.core.x

    @x.setter
    def x(self, x):
        self.core.x = x

    @property
    def y(self):
        return self.core.y

    @y.setter
    def y(self, y):
        self.core.y = y

    @property
    def z(self):
        return self.core.z

    @z.setter
    def z(self, z):
        self.core.z = z

    @property
    def reflectivity(self):
        return self.core.reflectivity

    @reflectivity.setter
    def reflectivity(self, reflectivity):
        self.core.reflectivity = reflectivity

# Class to wrap the LivoxExtendRawPoint struct
cdef class PyLivoxExtendRawPoint:
    '''
    Extend cartesian coordinate format.
    '''
    cdef LivoxExtendRawPoint core  # Correctly define core as a C struct

    def __init__(self, int x=0, int y=0, int z=0, uint8_t reflectivity=0, uint8_t tag=0):
        self.core = LivoxExtendRawPoint(x, y, z, reflectivity, tag)

    @property
    def x(self):
        return self.core.x

    @x.setter
    def x(self, x):
        self.core.x = x

    @property
    def y(self):
        return self.core.y

    @y.setter
    def y(self, y):
        self.core.y = y

    @property
    def z(self):
        return self.core.z

    @z.setter
    def z(self, z):
        self.core.z = z

    @property
    def reflectivity(self):
        return self.core.reflectivity

    @reflectivity.setter
    def reflectivity(self, reflectivity):
        self.core.reflectivity = reflectivity

    @property
    def tag(self):
        return self.core.tag

    @tag.setter
    def tag(self, tag):
        self.core.tag = tag

# Class to wrap the LivoxExtendSpherPoint struct
cdef class PyLivoxExtendSpherPoint:
    '''
    Extend spherical coordinate format.
    '''
    cdef LivoxExtendSpherPoint core  # Correctly define core as a C struct

    def __init__(self, uint32_t depth=0, uint16_t theta=0, uint16_t phi=0, uint8_t reflectivity=0, uint8_t tag=0):
        self.core = LivoxExtendSpherPoint(depth, theta, phi, reflectivity, tag)

    @property
    def depth(self):
        return self.core.depth

    @depth.setter
    def depth(self, depth):
        self.core.depth = depth

    @property
    def theta(self):
        return self.core.theta

    @theta.setter
    def theta(self, theta):
        self.core.theta = theta

    @property
    def phi(self):
        return self.core.phi

    @phi.setter
    def phi(self, phi):
        self.core.phi = phi

    @property
    def reflectivity(self):
        return self.core.reflectivity

    @reflectivity.setter
    def reflectivity(self, reflectivity):
        self.core.reflectivity = reflectivity

    @property
    def tag(self):
        return self.core.tag

    @tag.setter
    def tag(self, tag):
        self.core.tag = tag

# Class to wrap the LivoxDualExtendRawPoint struct
cdef class PyLivoxDualExtendRawPoint:
    '''
    Dual extend cartesian coordinate format.
    '''
    cdef LivoxDualExtendRawPoint core  # Correctly define core as a C struct

    def __init__(self, int x1=0, int y1=0, int z1=0, uint8_t reflectivity1=0, uint8_t tag1=0,
                 int x2=0, int y2=0, int z2=0, uint8_t reflectivity2=0, uint8_t tag2=0):
        self.core = LivoxDualExtendRawPoint(x1, y1, z1, reflectivity1, tag1, x2, y2, z2, reflectivity2, tag2)

    @property
    def x1(self):
        return self.core.x1

    @x1.setter
    def x1(self, x1):
        self.core.x1 = x1

    @property
    def y1(self):
        return self.core.y1

    @y1.setter
    def y1(self, y1):
        self.core.y1 = y1

    @property
    def z1(self):
        return self.core.z1

    @z1.setter
    def z1(self, z1):
        self.core.z1 = z1

    @property
    def reflectivity1(self):
        return self.core.reflectivity1

    @reflectivity1.setter
    def reflectivity1(self, reflectivity1):
        self.core.reflectivity1 = reflectivity1

    @property
    def tag1(self):
        return self.core.tag1

    @tag1.setter
    def tag1(self, tag1):
        self.core.tag1 = tag1

    @property
    def x2(self):
        return self.core.x2

    @x2.setter
    def x2(self, x2):
        self.core.x2 = x2

    @property
    def y2(self):
        return self.core.y2

    @y2.setter
    def y2(self, y2):
        self.core.y2 = y2

    @property
    def z2(self):
        return self.core.z2

    @z2.setter
    def z2(self, z2):
        self.core.z2 = z2

    @property
    def reflectivity2(self):
        return self.core.reflectivity2

    @reflectivity2.setter
    def reflectivity2(self, reflectivity2):
        self.core.reflectivity2 = reflectivity2

    @property
    def tag2(self):
        return self.core.tag2

    @tag2.setter
    def tag2(self, tag2):
        self.core.tag2 = tag2

# Class to wrap the LivoxDualExtendSpherPoint struct
cdef class PyLivoxDualExtendSpherPoint:
    '''
    Dual extend spherical coordinate format.
    '''
    cdef LivoxDualExtendSpherPoint core  # Correctly define core as a C struct

    def __init__(self, uint16_t theta=0, uint16_t phi=0, uint32_t depth1=0, uint8_t reflectivity1=0, uint8_t tag1=0,
                 uint32_t depth2=0, uint8_t reflectivity2=0, uint8_t tag2=0):
        self.core = LivoxDualExtendSpherPoint(theta, phi, depth1, reflectivity1, tag1, depth2, reflectivity2, tag2)

    @property
    def theta(self):
        return self.core.theta

    @theta.setter
    def theta(self, theta):
        self.core.theta = theta

    @property
    def phi(self):
        return self.core.phi

    @phi.setter
    def phi(self, phi):
        self.core.phi = phi

    @property
    def depth1(self):
        return self.core.depth1

    @depth1.setter
    def depth1(self, depth1):
        self.core.depth1 = depth1

    @property
    def reflectivity1(self):
        return self.core.reflectivity1

    @reflectivity1.setter
    def reflectivity1(self, reflectivity1):
        self.core.reflectivity1 = reflectivity1

    @property
    def tag1(self):
        return self.core.tag1

    @tag1.setter
    def tag1(self, tag1):
        self.core.tag1 = tag1

    @property
    def depth2(self):
        return self.core.depth2

    @depth2.setter
    def depth2(self, depth2):
        self.core.depth2 = depth2

    @property
    def reflectivity2(self):
        return self.core.reflectivity2

    @reflectivity2.setter
    def reflectivity2(self, reflectivity2):
        self.core.reflectivity2 = reflectivity2

    @property
    def tag2(self):
        return self.core.tag2

    @tag2.setter
    def tag2(self, tag2):
        self.core.tag2 = tag2

# Class to wrap the LivoxTripleExtendRawPoint struct
cdef class PyLivoxTripleExtendRawPoint:
    '''
    Triple extend cartesian coordinate format.
    '''
    cdef LivoxTripleExtendRawPoint core  # Correctly define core as a C struct

    def __init__(self, int x1=0, int y1=0, int z1=0, uint8_t reflectivity1=0, uint8_t tag1=0,
                 int x2=0, int y2=0, int z2=0, uint8_t reflectivity2=0, uint8_t tag2=0,
                 int x3=0, int y3=0, int z3=0, uint8_t reflectivity3=0, uint8_t tag3=0):
        self.core = LivoxTripleExtendRawPoint(x1, y1, z1, reflectivity1, tag1,
                                               x2, y2, z2, reflectivity2, tag2,
                                               x3, y3, z3, reflectivity3, tag3)

    @property
    def x1(self):
        return self.core.x1

    @x1.setter
    def x1(self, x1):
        self.core.x1 = x1

    @property
    def y1(self):
        return self.core.y1

    @y1.setter
    def y1(self, y1):
        self.core.y1 = y1

    @property
    def z1(self):
        return self.core.z1

    @z1.setter
    def z1(self, z1):
        self.core.z1 = z1

    @property
    def reflectivity1(self):
        return self.core.reflectivity1

    @reflectivity1.setter
    def reflectivity1(self, reflectivity1):
        self.core.reflectivity1 = reflectivity1

    @property
    def tag1(self):
        return self.core.tag1

    @tag1.setter
    def tag1(self, tag1):
        self.core.tag1 = tag1

    @property
    def x2(self):
        return self.core.x2

    @x2.setter
    def x2(self, x2):
        self.core.x2 = x2

    @property
    def y2(self):
        return self.core.y2

    @y2.setter
    def y2(self, y2):
        self.core.y2 = y2

    @property
    def z2(self):
        return self.core.z2

    @z2.setter
    def z2(self, z2):
        self.core.z2 = z2

    @property
    def reflectivity2(self):
        return self.core.reflectivity2

    @reflectivity2.setter
    def reflectivity2(self, reflectivity2):
        self.core.reflectivity2 = reflectivity2

    @property
    def tag2(self):
        return self.core.tag2

    @tag2.setter
    def tag2(self, tag2):
        self.core.tag2 = tag2

    @property
    def x3(self):
        return self.core.x3

    @x3.setter
    def x3(self, x3):
        self.core.x3 = x3

    @property
    def y3(self):
        return self.core.y3

    @y3.setter
    def y3(self, y3):
        self.core.y3 = y3

    @property
    def z3(self):
        return self.core.z3

    @z3.setter
    def z3(self, z3):
        self.core.z3 = z3

    @property
    def reflectivity3(self):
        return self.core.reflectivity3

    @reflectivity3.setter
    def reflectivity3(self, reflectivity3):
        self.core.reflectivity3 = reflectivity3

    @property
    def tag3(self):
        return self.core.tag3

    @tag3.setter
    def tag3(self, tag3):
        self.core.tag3 = tag3

# Class to wrap the LivoxTripleExtendSpherPoint struct
cdef class PyLivoxTripleExtendSpherPoint:
    '''
    Triple extend spherical coordinate format.
    '''
    cdef LivoxTripleExtendSpherPoint core  # Correctly define core as a C struct

    def __init__(self, uint16_t theta=0, uint16_t phi=0, uint32_t depth1=0, uint8_t reflectivity1=0, uint8_t tag1=0,
                 uint32_t depth2=0, uint8_t reflectivity2=0, uint8_t tag2=0,
                 uint32_t depth3=0, uint8_t reflectivity3=0, uint8_t tag3=0):
        self.core = LivoxTripleExtendSpherPoint(theta, phi, depth1, reflectivity1, tag1,
                                                  depth2, reflectivity2, tag2,
                                                  depth3, reflectivity3, tag3)

    @property
    def theta(self):
        return self.core.theta

    @theta.setter
    def theta(self, theta):
        self.core.theta = theta

    @property
    def phi(self):
        return self.core.phi

    @phi.setter
    def phi(self, phi):
        self.core.phi = phi

    @property
    def depth1(self):
        return self.core.depth1

    @depth1.setter
    def depth1(self, depth1):
        self.core.depth1 = depth1

    @property
    def reflectivity1(self):
        return self.core.reflectivity1

    @reflectivity1.setter
    def reflectivity1(self, reflectivity1):
        self.core.reflectivity1 = reflectivity1

    @property
    def tag1(self):
        return self.core.tag1

    @tag1.setter
    def tag1(self, tag1):
        self.core.tag1 = tag1

    @property
    def depth2(self):
        return self.core.depth2

    @depth2.setter
    def depth2(self, depth2):
        self.core.depth2 = depth2

    @property
    def reflectivity2(self):
        return self.core.reflectivity2

    @reflectivity2.setter
    def reflectivity2(self, reflectivity2):
        self.core.reflectivity2 = reflectivity2

    @property
    def tag2(self):
        return self.core.tag2

    @tag2.setter
    def tag2(self, tag2):
        self.core.tag2 = tag2

    @property
    def depth3(self):
        return self.core.depth3

    @depth3.setter
    def depth3(self, depth3):
        self.core.depth3 = depth3

    @property
    def reflectivity3(self):
        return self.core.reflectivity3

    @reflectivity3.setter
    def reflectivity3(self, reflectivity3):
        self.core.reflectivity3 = reflectivity3

    @property
    def tag3(self):
        return self.core.tag3

    @tag3.setter
    def tag3(self, tag3):
        self.core.tag3 = tag3

cdef class PyLivoxImuPoint:
    '''
    IMU data format.
    '''
    cdef LivoxImuPoint core  # Correctly define core as a C struct

    def __init__(self, float gyro_x=0, float gyro_y=0, float gyro_z=0, 
                 float acc_x=0, float acc_y=0, float acc_z=0):
        self.core = LivoxImuPoint(gyro_x, gyro_y, gyro_z, acc_x, acc_y, acc_z)

    @property
    def gyro_x(self):
        return self.core.gyro_x

    @gyro_x.setter
    def gyro_x(self, gyro_x):
        self.core.gyro_x = gyro_x

    @property
    def gyro_y(self):
        return self.core.gyro_y

    @gyro_y.setter
    def gyro_y(self, gyro_y):
        self.core.gyro_y = gyro_y

    @property
    def gyro_z(self):
        return self.core.gyro_z

    @gyro_z.setter
    def gyro_z(self, gyro_z):
        self.core.gyro_z = gyro_z

    @property
    def acc_x(self):
        return self.core.acc_x

    @acc_x.setter
    def acc_x(self, acc_x):
        self.core.acc_x = acc_x

    @property
    def acc_y(self):
        return self.core.acc_y

    @acc_y.setter
    def acc_y(self, acc_y):
        self.core.acc_y = acc_y

    @property
    def acc_z(self):
        return self.core.acc_z

    @acc_z.setter
    def acc_z(self, acc_z):
        self.core.acc_z = acc_z

# Class to wrap the LidarErrorCode struct
cdef class PyLidarErrorCode:
    '''
    LiDAR error code.
    '''
    cdef LidarErrorCode core  # Correctly define core as a C struct

    def __init__(self, uint32_t temp_status=0, uint32_t volt_status=0, uint32_t motor_status=0,
                 uint32_t dirty_warn=0, uint32_t firmware_err=0, uint32_t pps_status=0,
                 uint32_t device_status=0, uint32_t fan_status=0, uint32_t self_heating=0,
                 uint32_t ptp_status=0, uint32_t time_sync_status=0, uint32_t rsvd=0,
                 uint32_t system_status=0):
        self.core = LidarErrorCode(temp_status, volt_status, motor_status, dirty_warn,
                                    firmware_err, pps_status, device_status, fan_status,
                                    self_heating, ptp_status, time_sync_status, rsvd,
                                    system_status)

    @property
    def temp_status(self):
        return self.core.temp_status

    @temp_status.setter
    def temp_status(self, temp_status):
        self.core.temp_status = temp_status

    @property
    def volt_status(self):
        return self.core.volt_status

    @volt_status.setter
    def volt_status(self, volt_status):
        self.core.volt_status = volt_status

    @property
    def motor_status(self):
        return self.core.motor_status

    @motor_status.setter
    def motor_status(self, motor_status):
        self.core.motor_status = motor_status

    @property
    def dirty_warn(self):
        return self.core.dirty_warn

    @dirty_warn.setter
    def dirty_warn(self, dirty_warn):
        self.core.dirty_warn = dirty_warn

    @property
    def firmware_err(self):
        return self.core.firmware_err

    @firmware_err.setter
    def firmware_err(self, firmware_err):
        self.core.firmware_err = firmware_err

    @property
    def pps_status(self):
        return self.core.pps_status

    @pps_status.setter
    def pps_status(self, pps_status):
        self.core.pps_status = pps_status

    @property
    def device_status(self):
        return self.core.device_status

    @device_status.setter
    def device_status(self, device_status):
        self.core.device_status = device_status

    @property
    def fan_status(self):
        return self.core.fan_status

    @fan_status.setter
    def fan_status(self, fan_status):
        self.core.fan_status = fan_status

    @property
    def self_heating(self):
        return self.core.self_heating

    @self_heating.setter
    def self_heating(self, self_heating):
        self.core.self_heating = self_heating

    @property
    def ptp_status(self):
        return self.core.ptp_status

    @ptp_status.setter
    def ptp_status(self, ptp_status):
        self.core.ptp_status = ptp_status

    @property
    def time_sync_status(self):
        return self.core.time_sync_status

    @time_sync_status.setter
    def time_sync_status(self, time_sync_status):
        self.core.time_sync_status = time_sync_status

    @property
    def rsvd(self):
        return self.core.rsvd

    @rsvd.setter
    def rsvd(self, rsvd):
        self.core.rsvd = rsvd

    @property
    def system_status(self):
        return self.core.system_status

    @system_status.setter
    def system_status(self, system_status):
        self.core.system_status = system_status

# Class to wrap the HubErrorCode struct
cdef class PyHubErrorCode:
    '''
    Hub error code.
    '''
    cdef HubErrorCode core  # Correctly define core as a C struct

    def __init__(self, uint32_t sync_status=0, uint32_t temp_status=0, uint32_t lidar_status=0,
                 uint32_t lidar_link_status=0, uint32_t firmware_err=0, uint32_t rsvd=0,
                 uint32_t system_status=0):
        self.core = HubErrorCode(sync_status, temp_status, lidar_status, lidar_link_status,
                                  firmware_err, rsvd, system_status)

    @property
    def sync_status(self):
        return self.core.sync_status

    @sync_status.setter
    def sync_status(self, sync_status):
        self.core.sync_status = sync_status

    @property
    def temp_status(self):
        return self.core.temp_status

    @temp_status.setter
    def temp_status(self, temp_status):
        self.core.temp_status = temp_status

    @property
    def lidar_status(self):
        return self.core.lidar_status

    @lidar_status.setter
    def lidar_status(self, lidar_status):
        self.core.lidar_status = lidar_status

    @property
    def lidar_link_status(self):
        return self.core.lidar_link_status

    @lidar_link_status.setter
    def lidar_link_status(self, lidar_link_status):
        self.core.lidar_link_status = lidar_link_status

    @property
    def firmware_err(self):
        return self.core.firmware_err

    @firmware_err.setter
    def firmware_err(self, firmware_err):
        self.core.firmware_err = firmware_err

    @property
    def rsvd(self):
        return self.core.rsvd

    @rsvd.setter
    def rsvd(self, rsvd):
        self.core.rsvd = rsvd

    @property
    def system_status(self):
        return self.core.system_status

    @system_status.setter
    def system_status(self, system_status):
        self.core.system_status = system_status

# Class to wrap the ErrorMessage union
cdef class PyErrorMessage:
    '''
    Device error message.
    '''
    cdef ErrorMessage core  # Correctly define core as a C union

    def __init__(self, uint32_t error_code=0, PyLidarErrorCode lidar_error_code=PyLidarErrorCode(), 
                 PyHubErrorCode hub_error_code=PyHubErrorCode()):
        self.core.lidar_error_code = lidar_error_code.core  # Assigning the LidarErrorCode
        self.core.hub_error_code = hub_error_code.core  # Assigning the HubErrorCode
        self.core.error_code = error_code  # Default to error code

    # Property for accessing the error code
    @property
    def error_code(self):
        return self.core.error_code

    @error_code.setter
    def error_code(self, error_code):
        self.core.error_code = error_code

    # Property for accessing the LidarErrorCode
    @property
    def lidar_error_code(self):
        return self.core.lidar_error_code

    @lidar_error_code.setter
    def lidar_error_code(self, lidar_error_code):
        self.core.lidar_error_code = lidar_error_code.core

    # Property for accessing the HubErrorCode
    @property
    def hub_error_code(self):
        return self.core.hub_error_code

    @hub_error_code.setter
    def hub_error_code(self, hub_error_code):
        self.core.hub_error_code = hub_error_code.core

# Class to wrap LivoxEthPacket
cdef class PyLivoxEthPacket:
    '''
    Point cloud packet.
    '''
    cdef LivoxEthPacket core

    def __init__(self, uint8_t version=0, uint8_t slot=0, uint8_t id=0, uint32_t err_code=0, 
            uint8_t timestamp_type=0, uint8_t data_type=0, timestamp=[0 for _ in range(8)], 
                  data=[0]):
        self.core.version = version
        self.core.slot = slot
        self.core.id = id
        self.core.err_code = err_code
        self.core.timestamp_type = timestamp_type
        self.core.data_type = data_type
        self.core.timestamp = timestamp[:8]
        self.core.data = data[:1]

    @property
    def version(self):
        return self.core.version

    @version.setter
    def version(self, value):
        self.core.version = value

    @property
    def slot(self):
        return self.core.slot

    @slot.setter
    def slot(self, value):
        self.core.slot = value

    @property
    def id(self):
        return self.core.id

    @id.setter
    def id(self, value):
        self.core.id = value

    @property
    def err_code(self):
        return self.core.err_code

    @err_code.setter
    def err_code(self, value):
        self.core.err_code = value

    @property
    def timestamp_type(self):
        return self.core.timestamp_type

    @timestamp_type.setter
    def timestamp_type(self, value):
        self.core.timestamp_type = value

    @property
    def data_type(self):
        return self.core.data_type

    @data_type.setter
    def data_type(self, value):
        self.core.data_type = value

    @property
    def timestamp(self):
        return self.core.timestamp

    @timestamp.setter
    def timestamp(self, value):
        self.core.timestamp = value

    @property
    def data(self):
        return self.core.data

    @data.setter
    def data(self, value):
        self.core.data = value 

# Class to wrap StatusUnion
cdef class PyStatusUnion:
    '''
    Information of LiDAR work state.
    '''
    cdef StatusUnion core

    def __init__(self, uint32_t progress=0, PyErrorMessage status_code=PyErrorMessage()):
        self.core.progress = progress
        self.core.status_code = status_code.core

    @property
    def progress(self):
        return self.core.progress

    @progress.setter
    def progress(self, value):
        self.core.progress = value

    @property
    def status_code(self):
        return self.core.status_code

    @status_code.setter
    def status_code(self, value):
        self.core.status_code = value.core

# Class to wrap DeviceInfo
cdef class PyDeviceInfo:
    '''
    Information of the connected LiDAR or hub.
    '''
    cdef DeviceInfo core

    def __init__(self, broadcast_code='0'*kBroadcastCodeSize, uint8_t handle=0,
                 uint8_t slot=0, uint8_t id=0, 
                 uint8_t type=0, uint16_t data_port=0, uint16_t cmd_port=0, uint16_t sensor_port=0, 
                  ip='0'*16, 
                 state=0, feature=0, 
                 PyStatusUnion status=PyStatusUnion(), firmware_version=[0 for _ in range(4)]):
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize - 1]  # Ensure null-termination
        self.core.handle = handle
        self.core.slot = slot
        self.core.id = id
        self.core.type = type
        self.core.data_port = data_port
        self.core.cmd_port = cmd_port
        self.core.sensor_port = sensor_port
        self.core.ip = ip.encode('utf-8')[:16]  # Ensure null-termination
        self.core.state = state
        self.core.feature = feature
        self.core.status = status.core
        self.core.firmware_version = firmware_version[:4]  # Ensure length

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')  # Convert bytes to string

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]  # Ensure null-termination

    @property
    def handle(self):
        return self.core.handle

    @handle.setter
    def handle(self, value):
        self.core.handle = value

    @property
    def slot(self):
        return self.core.slot

    @slot.setter
    def slot(self, value):
        self.core.slot = value

    @property
    def id(self):
        return self.core.id

    @id.setter
    def id(self, value):
        self.core.id = value

    @property
    def type(self):
        return self.core.type

    @type.setter
    def type(self, value):
        self.core.type = value

    @property
    def data_port(self):
        return self.core.data_port

    @data_port.setter
    def data_port(self, value):
        self.core.data_port = value

    @property
    def cmd_port(self):
        return self.core.cmd_port

    @cmd_port.setter
    def cmd_port(self, value):
        self.core.cmd_port = value

    @property
    def sensor_port(self):
        return self.core.sensor_port

    @sensor_port.setter
    def sensor_port(self, value):
        self.core.sensor_port = value

    @property
    def ip(self):
        return self.core.ip.decode('utf-8')  # Convert bytes to string

    @ip.setter
    def ip(self, value):
        self.core.ip = value.encode('utf-8')[:16]  # Ensure null-termination

    @property
    def state(self):
        return self.core.state

    @state.setter
    def state(self, value):
        self.core.state = value

    @property
    def feature(self):
        return self.core.feature

    @feature.setter
    def feature(self, value):
        self.core.feature = value

    @property
    def status(self):
        return self.core.status

    @status.setter
    def status(self, value):
        self.core.status = value.core

    @property
    def firmware_version(self):
        return self.core.firmware_version  # Can be converted to string if needed

    @firmware_version.setter
    def firmware_version(self, value):
        self.core.firmware_version = value[:4]

# Class to wrap BroadcastDeviceInfo
cdef class PyBroadcastDeviceInfo:
    '''
    The information of broadcast device.
    '''
    cdef BroadcastDeviceInfo core

    def __init__(self, broadcast_code='0'*kBroadcastCodeSize, 
                 uint8_t dev_type=0, uint16_t reserved=0, ip='0'*16):
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize-1]  # Ensure null-termination
        self.core.dev_type = dev_type
        self.core.reserved = reserved
        self.core.ip = ip.encode('utf-8')[:16]  # Ensure null-termination

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')  # Convert bytes to string

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]  # Ensure null-termination

    @property
    def dev_type(self):
        return self.core.dev_type

    @dev_type.setter
    def dev_type(self, value):
        self.core.dev_type = value

    @property
    def reserved(self):
        return self.core.reserved

    @reserved.setter
    def reserved(self, value):
        self.core.reserved = value

    @property
    def ip(self):
        return self.core.ip.decode('utf-8')  # Convert bytes to string

    @ip.setter
    def ip(self, value):
        self.core.ip = value.encode('utf-8')[:16]  # Ensure null-termination

cdef class PyConnectedLidarInfo:
    '''
    The information of LiDAR units that are connected to the Livox Hub.
    '''
    cdef ConnectedLidarInfo core
    
    def __init__(self, broadcast_code='0'*kBroadcastCodeSize, uint8_t dev_type=0, version=[0 for _ in range(4)], 
            uint8_t slot=0, uint8_t id=0):
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize-1]
        self.core.dev_type = dev_type
        self.core.version = version[:4]
        self.core.slot = slot
        self.core.id = id

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]

    @property
    def dev_type(self):
        return self.core.dev_type

    @dev_type.setter
    def dev_type(self, value):
        self.core.dev_type = value

    @property
    def version(self):
        return self.core.version

    @version.setter
    def version(self, value):
        self.core.version = value[:4]

    @property
    def slot(self):
        return self.core.slot

    @slot.setter
    def slot(self, value):
        self.core.slot = value

    @property
    def id(self):
        return self.core.id

    @id.setter
    def id(self, value):
        self.core.id = value

cdef class PyLidarModeRequestItem:
    '''
    LiDAR mode configuration information.
    '''
    cdef LidarModeRequestItem core

    def __init__(self, broadcast_code='0'*kBroadcastCodeSize, uint8_t state=0):
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize-1]
        self.core.state = state

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]

    @property
    def state(self):
        return self.core.state

    @state.setter
    def state(self, value):
        self.core.state = value

cdef class PyReturnCode:
    '''
    '''
    cdef ReturnCode core

    def __init__(self, uint8_t ret_code=0, broadcast_code='0'*kBroadcastCodeSize):
        self.core.ret_code = ret_code
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize-1]

    @property
    def ret_code(self):
        return self.core.ret_code

    @ret_code.setter
    def ret_code(self, value):
        self.core.ret_code = value

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]

cdef class PyDeviceBroadcastCode:
    '''
    '''
    cdef DeviceBroadcastCode core

    def __init__(self, broadcast_code='0'*kBroadcastCodeSize):
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize-1]

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]

cdef class PyRainFogSuppressRequestItem:
    '''
    '''
    cdef RainFogSuppressRequestItem core

    def __init__(self, broadcast_code='0'*kBroadcastCodeSize, uint8_t feature=0):
        self.core.broadcast_code = broadcast_code.encode('utf-8')[:kBroadcastCodeSize-1]
        self.core.feature = feature

    @property
    def broadcast_code(self):
        return self.core.broadcast_code.decode('utf-8')

    @broadcast_code.setter
    def broadcast_code(self, value):
        self.core.broadcast_code = value.encode('utf-8')[:kBroadcastCodeSize-1]

    @property
    def feature(self):
        return self.core.feature

    @feature.setter
    def feature(self, value):
        self.core.feature = value

cdef class PyLidarGetExtrinsicParameterResponse:
    '''
    The response body of getting Livox LiDAR's parameters.
    '''
    cdef LidarGetExtrinsicParameterResponse core

    def __init__(self, uint8_t ret_code=0, float roll=0, float pitch=0, float yaw=0, 
                 int32_t x=0, int32_t y=0, int32_t z=0):
        self.core.ret_code = ret_code
        self.core.roll = roll
        self.core.pitch = pitch
        self.core.yaw = yaw
        self.core.x = x
        self.core.y = y
        self.core.z = z

    @property
    def ret_code(self):
        return self.core.ret_code

    @ret_code.setter
    def ret_code(self, value):
        self.core.ret_code = value

    @property
    def roll(self):
        return self.core.roll

    @roll.setter
    def roll(self, value):
        self.core.roll = value

    @property
    def pitch(self):
        return self.core.pitch

    @pitch.setter
    def pitch(self, value):
        self.core.pitch = value

    @property
    def yaw(self):
        return self.core.yaw

    @yaw.setter
    def yaw(self, value):
        self.core.yaw = value

    @property
    def x(self):
        return self.core.x

    @x.setter
    def x(self, value):
        self.core.x = value

    @property
    def y(self):
        return self.core.y

    @y.setter
    def y(self, value):
        self.core.y = value

    @property
    def z(self):
        return self.core.z

    @z.setter
    def z(self, value):
        self.core.z = value

cdef class PyDeviceInformationResponse:
    '''
    The response body of querying device information.
    '''
    cdef DeviceInformationResponse core

    def __init__(self, uint8_t ret_code=0, firmware_version=[0 for i in range(4)]):
        self.core.ret_code = ret_code
        self.firmware_version = firmware_version[:4]

    @property
    def ret_code(self):
        return self.core.ret_code

    @ret_code.setter
    def ret_code(self, value):
        self.core.ret_code = value

    @property
    def firmware_version(self):
        return self.core.firmware_version

    @firmware_version.setter
    def firmware_version(self, value):
        self.core.firmware_version = value[:4]
 
 
