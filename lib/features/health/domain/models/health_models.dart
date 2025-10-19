// lib/features/health/domain/models/health_models.dart

class PrescriptionMedication {
  final String id;
  final String prescriptionId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;
  final DateTime createdAt;

  PrescriptionMedication({
    required this.id,
    required this.prescriptionId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
    required this.createdAt,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedication(
      id: json['id'] as String,
      prescriptionId: json['prescription_id'] as String,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class MedicalTest {
  final String id;
  final String prescriptionId;
  final String testName;
  final String? testReason;
  final String urgency; // 'urgent', 'normal', 'routine'
  final DateTime createdAt;

  MedicalTest({
    required this.id,
    required this.prescriptionId,
    required this.testName,
    this.testReason,
    required this.urgency,
    required this.createdAt,
  });

  factory MedicalTest.fromJson(Map<String, dynamic> json) {
    return MedicalTest(
      id: json['id'] as String,
      prescriptionId: json['prescription_id'] as String,
      testName: json['test_name'] as String,
      testReason: json['test_reason'] as String?,
      urgency: json['urgency'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Prescription {
  final String id;
  final String? healthRecordId;
  final String? consultationId;
  final String patientId;
  final String doctorId;
  final String? diagnosis;
  final String? symptoms;
  final String? medicalNotes;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined data
  final String doctorName;
  final String? doctorProfileUrl;
  final String doctorSpecialization;
  final List<PrescriptionMedication> medications;
  final List<MedicalTest> tests;

  Prescription({
    required this.id,
    this.healthRecordId,
    this.consultationId,
    required this.patientId,
    required this.doctorId,
    this.diagnosis,
    this.symptoms,
    this.medicalNotes,
    this.followUpDate,
    required this.createdAt,
    this.updatedAt,
    required this.doctorName,
    this.doctorProfileUrl,
    required this.doctorSpecialization,
    this.medications = const [],
    this.tests = const [],
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    // Parse medications
    final medicationsList = <PrescriptionMedication>[];
    if (json['prescription_medications'] != null) {
      medicationsList.addAll(
        (json['prescription_medications'] as List)
            .map((m) => PrescriptionMedication.fromJson(m))
            .toList(),
      );
    }

    // Parse tests
    final testsList = <MedicalTest>[];
    if (json['medical_tests'] != null) {
      testsList.addAll(
        (json['medical_tests'] as List)
            .map((t) => MedicalTest.fromJson(t))
            .toList(),
      );
    }

    // Extract doctor info
    final doctorData = json['doctors'] as Map<String, dynamic>?;
    final userData = doctorData?['users'] as Map<String, dynamic>?;

    return Prescription(
      id: json['id'] as String,
      healthRecordId: json['health_record_id'] as String?,
      consultationId: json['consultation_id'] as String?,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      diagnosis: json['diagnosis'] as String?,
      symptoms: json['symptoms'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      followUpDate: json['follow_up_date'] != null
          ? DateTime.parse(json['follow_up_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      doctorName: userData?['full_name'] as String? ?? 'Doctor',
      doctorProfileUrl: userData?['profile_picture_url'] as String?,
      doctorSpecialization:
          doctorData?['specialization'] as String? ?? 'General',
      medications: medicationsList,
      tests: testsList,
    );
  }
}
