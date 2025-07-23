class PhoneAuthState {
  final String verificationId;
  final bool isLoading;
  final String? error;
  final String? firebaseToken;

  PhoneAuthState({
    required this.verificationId,
    this.isLoading = false,
    this.error,
    this.firebaseToken,
  });

  PhoneAuthState copyWith({
    String? verificationId,
    bool? isLoading,
    String? error,
    String? firebaseToken,
  }) {
    return PhoneAuthState(
      verificationId: verificationId ?? this.verificationId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      firebaseToken: firebaseToken ?? this.firebaseToken,
    );
  }
}
