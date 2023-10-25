#ifndef FLUTTER_PLUGIN_GMPAY_PLUGIN_H_
#define FLUTTER_PLUGIN_GMPAY_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace gmpay {

class GmpayPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  GmpayPlugin();

  virtual ~GmpayPlugin();

  // Disallow copy and assign.
  GmpayPlugin(const GmpayPlugin&) = delete;
  GmpayPlugin& operator=(const GmpayPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace gmpay

#endif  // FLUTTER_PLUGIN_GMPAY_PLUGIN_H_
