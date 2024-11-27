import pylivox
from enum import Enum
from pylivox import kMaxLidarCount

class DeviceState(Enum):
    kDeviceStateDisconnect = 0
    kDeviceStateConnect = 1
    kDeviceStateSampling = 2

class DeviceItem:

    def __init__(handle, device_state, info):
        self.handle = handle
        self.device_state = device_state
        self.info = info

devices = [DeviceItem for _ in range(kMaxLidarCount)]

def OnSampleCallback(status, handle, response):
    print(f"OnSampleCallback status {status} handle {handle} response {response} \n")
    if status == pylivox.PyLivoxStatus.StatusSucess():
        if response != 0:
            devices[handle].device_state = DeviceState.kDeviceStateConnect
    elif status == pylivox.PyLivoxStatus.StatusTimeout():
        devices[handle].device_state = DeviceState.kDeviceStateConnect

if __name__ == "__main__":
    flag = pylivox.PyInit()
    print(f'py_Init(): {flag}')
    flag = False
    flag = pylivox.PyStart()
    print(f'py_Start(): {flag}')
    pylivox.PyUninit()
    pylivox.PySaveLoggerFile()
    pylivox.PyDisableConsoleLogger()
    status = pylivox.PyLivoxStatus.StatusSendFailed()
    point = pylivox.PyLivoxSpherPoint(0, 0, 0, 0)
    print(status)
    print(point.depth)
    point.depth += 1
    print(point.depth)
    version = pylivox.PyLivoxSdkVersion()
    pylivox.PyGetLivoxSdkVersion(version)
    print(version.major, version.minor, version.patch)
    packet = pylivox.PyLivoxEthPacket()
    packet.timestamp = [1, 1, 1, 0, 0, 0, 0, 0]
    print(packet.timestamp[1])
    info = pylivox.PyBroadcastDeviceInfo()
    info.ip = '0101010101010101'
    info.broadcast_code = '0101010101010101'
    print(info.broadcast_code)
    status = pylivox.PyHubStartSampling(OnSampleCallback)
    print(status)
