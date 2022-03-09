import dbus

try:
  bus = dbus.SystemBus()
  device = bus.get_object('org.bluez', '/org/bluez/hci0/dev_38_18_4C_06_73_70')
  iface = dbus.Interface(device, 'org.freedesktop.DBus.Properties')
  battery_level = int(iface.Get('org.bluez.Battery1', 'Percentage'))

  print(f'🎧 {battery_level}%')
except:
  pass
