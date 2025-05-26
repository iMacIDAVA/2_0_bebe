import 'package:flutter/material.dart';

class Constants {


  // API Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String consultationsEndpoint = '/consultation/';
  static const String doctorsEndpoint = '/doctors/';
  static const String patientsEndpoint = '/patients/';
  static const String paymentsEndpoint = '/payments/';

  // Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color secondaryColor = Color(0xFF81C784); // Light Green
  static const Color accentColor = Color(0xFF2E7D32); // Dark Green
  static const Color errorColor = Color(0xFFE57373); // Light Red
  static const Color successColor = Color(0xFF81C784); // Light Green
  static const Color warningColor = Color(0xFFFFB74D); // Light Orange
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF212121); // Dark Grey
  static const Color lightTextColor = Color(0xFF757575); // Grey

  // Text Styles
  static final TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static final TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static final TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: lightTextColor,
  );

  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration consultationTimeout = Duration(minutes: 3);
  static const Duration pollingInterval = Duration(seconds: 5);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String consultationDataKey = 'consultation_data';

  // Error Messages
  static const String networkError = 'Network error occurred. Please try again.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidAgeMessage = 'Please enter a valid age';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String consultationRequestSuccess = 'Consultation request sent successfully';
  static const String paymentSuccess = 'Payment successful';
  static const String formSubmissionSuccess = 'Form submitted successfully';

  // Status Messages
  static const String waitingForDoctorMessage = 'Waiting for doctor to accept your request...';
  static const String noConsultationMessage = 'No active consultation';
  static const String consultationEndedMessage = 'Consultation has ended';
  static const String paymentPendingMessage = 'Payment pending';
  static const String formPendingMessage = 'Medical form pending';

  // Button Text
  static const String loginText = 'Login';
  static const String registerText = 'Register';
  static const String submitText = 'Submit';
  static const String cancelText = 'Cancel';
  static const String proceedToPaymentText = 'Proceed to Payment';
  static const String requestConsultationText = 'Request Consultation';
  static const String cancelRequestText = 'Cancel Request';
  static const String joinSessionText = 'Join Session';
  static const String fillFormText = 'Fill Medical Form';

  // Form Labels
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String nameLabel = 'Full Name';
  static const String phoneLabel = 'Phone Number';
  static const String reasonForConsultationLabel = 'Reason for Consultation';
  static const String symptomsLabel = 'Symptoms';
  static const String ageLabel = 'Age';
  static const String genderLabel = 'Gender';
  static const String allergiesLabel = 'Allergies (if any)';
  static const String chronicConditionsLabel = 'Chronic Conditions (if any)';
  static const String medicationsLabel = 'Current Medications (if any)';
  static const String previousSurgeriesLabel = 'Previous Surgeries (if any)';

  // Validation Messages
  static const String invalidEmailMessage = 'Please enter a valid email address';
  static const String invalidPasswordMessage = 'Password must be at least 8 characters';
  static const String passwordMismatchMessage = 'Passwords do not match';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String invalidNameMessage = 'Please enter your full name';
}