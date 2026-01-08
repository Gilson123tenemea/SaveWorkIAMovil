class FCMTokenRegistro {
  final String tokenFcm;

  FCMTokenRegistro({
    required this.tokenFcm,
  });

  Map<String, dynamic> toJson() {
    return {
      'token_fcm': tokenFcm,
    };
  }
}

class FCMTokenResponse {
  final int idFcmToken;
  final int idInspector;
  final String tokenFcm;
  final String mensaje;

  FCMTokenResponse({
    required this.idFcmToken,
    required this.idInspector,
    required this.tokenFcm,
    required this.mensaje,
  });

  factory FCMTokenResponse.fromJson(Map<String, dynamic> json) {
    return FCMTokenResponse(
      idFcmToken: json['id_fcm_token'],
      idInspector: json['id_inspector'],
      tokenFcm: json['token_fcm'],
      mensaje: json['mensaje'],
    );
  }
}