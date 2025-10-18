// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DocSync';

  @override
  String get home => 'Home';

  @override
  String get consult => 'Consult';

  @override
  String get ai => 'AI';

  @override
  String get health => 'Health';

  @override
  String get profile => 'Profile';

  @override
  String get hi => 'Hi';

  @override
  String get howIsYourHealth => 'How is your health?';

  @override
  String get upcomingSchedule => 'Upcoming Schedule';

  @override
  String get seeAll => 'See All';

  @override
  String get noUpcomingSchedule => 'No upcoming schedule';

  @override
  String availableIn(Object time) {
    return 'Available in $time';
  }

  @override
  String get categories => 'Categories';

  @override
  String get allCategories => 'All Categories';

  @override
  String get topDoctors => 'Top Doctors';

  @override
  String get allDoctors => 'All Doctors';

  @override
  String get noDoctorsAvailable => 'No Doctors Available';

  @override
  String get checkBackLater => 'Check back later.';

  @override
  String get errorLoadingDoctors => 'Error Loading Doctors';

  @override
  String get retry => 'Retry';

  @override
  String get available => 'Available';

  @override
  String get offline => 'Offline';

  @override
  String get neurologist => 'Neurologist';

  @override
  String get neuromedicine => 'Neuromedicine';

  @override
  String get neurosurgeon => 'Neurosurgeon';

  @override
  String get nutritionist => 'Nutritionist';

  @override
  String get oncologist => 'Oncologist';

  @override
  String get ophthalmologist => 'Ophthalmologist';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা (Bangla)';

  @override
  String get languageChangedToEnglish => 'Language changed to English';

  @override
  String get subscriptionsAndCarePlans => 'Subscriptions & Care Plans';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get signOut => 'Sign out';

  @override
  String get cancel => 'Cancel';

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String get findDoctor => 'Find Doctor';

  @override
  String get searchDoctorByName => 'Search doctor by name...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get trySearchingWithDifferentKeywords =>
      'Try searching with different keywords';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get chatWithAI => 'Chat with AI';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get send => 'Send';
}
