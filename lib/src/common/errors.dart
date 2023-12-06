class FancyErrorCodes {
  static const int noInternetNebula = 0x001;
  static const int quantumQuandary = 0x002;
  static const int cosmicConnectionCollapse = 0x003;
  static const int ephemeralEncryptionError = 0x004;
  static const int celestialCollision = 0x005;
  static const int supernovaShutdown = 0x006;
  static const int aetherialAccessAnomaly = 0x007;
  static const int galacticGatewayGlitch = 0x008;
  static const int astralAuthenticationAberration = 0x009;
  static const int lunarLoadingLapse = 0x00A;
  static const int interstellarInputInconsistency = 0x00B;
  static const int temporalTransformationError = 0x00C;
  static const int plasmaPermissionProblem = 0x00D;
  static const int etherealExecutionException = 0x00E;
  static const int zephyrZeroDivision = 0x00F;

  static Map<int, String> errorMessages = {
    noInternetNebula: "No Internet Connection",
    quantumQuandary: "Unexpected Error",
    cosmicConnectionCollapse: "Network Timeout",
    ephemeralEncryptionError: "Security Breach",
    celestialCollision: "Data Conflict",
    supernovaShutdown: "Server Unreachable",
    aetherialAccessAnomaly: "Unauthorized Access",
    galacticGatewayGlitch: "Gateway Timeout",
    astralAuthenticationAberration: "Authentication Failure",
    lunarLoadingLapse: "Slow Connection",
    interstellarInputInconsistency: "Invalid Input",
    temporalTransformationError: "Time Out of Sync",
    plasmaPermissionProblem: "Insufficient Permissions",
    etherealExecutionException: "Runtime Error",
    zephyrZeroDivision: "Divide by Zero",
  };

  static String getErrorMessage(int errorCode) {
    return errorMessages[errorCode] ?? "Unknown Error";
  }

  //get code to hex representation
  static String getCode(int errorCode) {
    return "0x${errorCode.toRadixString(16).toUpperCase()}";
  }
}
