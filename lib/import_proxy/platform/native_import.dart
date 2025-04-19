
import 'package:tencent_cloud_chat_uikit/import_proxy/import_proxy.dart';

class NativeImport implements ImportProxy {
  @override
  getFlutterPluginRecord() {
    return null;
  }
}

ImportProxy getImportProxy() => NativeImport();
