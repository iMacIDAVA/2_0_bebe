class DoctorStatusService {
  static final DoctorStatusService _instance = DoctorStatusService._internal();
  factory DoctorStatusService() => _instance;

  DoctorStatusService._internal();

  final Map<int, bool> doctorBusyStatus = {};
}

final doctorStatusService = DoctorStatusService();
