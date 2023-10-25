#include "include/gmpay/gmpay_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "gmpay_plugin.h"

void GmpayPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  gmpay::GmpayPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
