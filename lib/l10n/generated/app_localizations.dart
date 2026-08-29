import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sallaamti Nikah Counselor'**
  String get appName;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get urdu;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Nikah Counselor Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the credentials you were given when you were certified.'**
  String get loginSubtitle;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone'**
  String get emailOrPhone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @notCounselorAccount.
  ///
  /// In en, this message translates to:
  /// **'This account isn\'t a Nikah Counselor account. Contact Sallaamti if you believe this is a mistake.'**
  String get notCounselorAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Not a counselor yet?'**
  String get noAccountYet;

  /// No description provided for @applyHere.
  ///
  /// In en, this message translates to:
  /// **'Apply Here'**
  String get applyHere;

  /// No description provided for @applyTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a Nikah Counselor'**
  String get applyTitle;

  /// No description provided for @applySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill this out and our team will review your application. Once approved and certified, you\'ll be able to log in and start working.'**
  String get applySubtitle;

  /// No description provided for @applyWhatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number (if different)'**
  String get applyWhatsappLabel;

  /// No description provided for @applyAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get applyAgeLabel;

  /// No description provided for @applyMaritalStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get applyMaritalStatusLabel;

  /// No description provided for @applyQualificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get applyQualificationLabel;

  /// No description provided for @applySelfieLabel.
  ///
  /// In en, this message translates to:
  /// **'Selfie Photo'**
  String get applySelfieLabel;

  /// No description provided for @applyAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get applyAreaLabel;

  /// No description provided for @applyAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get applyAddressLabel;

  /// No description provided for @applyPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission Payout Details (optional)'**
  String get applyPayoutTitle;

  /// No description provided for @applyPayoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can add this later too — only needed once you start earning commission.'**
  String get applyPayoutSubtitle;

  /// No description provided for @applyPayoutTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Title'**
  String get applyPayoutTitleLabel;

  /// No description provided for @applyPayoutNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account / Mobile Number'**
  String get applyPayoutNumberLabel;

  /// No description provided for @applyPayoutBankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get applyPayoutBankLabel;

  /// No description provided for @applyConsentText.
  ///
  /// In en, this message translates to:
  /// **'I consent to Sallaamti verifying my identity and processing my application.'**
  String get applyConsentText;

  /// No description provided for @applyTermsText.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Nikah Counselor terms and code of conduct.'**
  String get applyTermsText;

  /// No description provided for @applyConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept both checkboxes to continue.'**
  String get applyConsentRequired;

  /// No description provided for @applyPhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'Please add your selfie and both sides of your CNIC.'**
  String get applyPhotosRequired;

  /// No description provided for @applySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get applySubmit;

  /// No description provided for @applySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your application has been received — our team will review it and be in touch soon.'**
  String get applySubmitted;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @statNewLeads.
  ///
  /// In en, this message translates to:
  /// **'New Leads'**
  String get statNewLeads;

  /// No description provided for @statFollowUpsDue.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups Due'**
  String get statFollowUpsDue;

  /// No description provided for @statRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get statRegistered;

  /// No description provided for @statActiveBatches.
  ///
  /// In en, this message translates to:
  /// **'Active Batches'**
  String get statActiveBatches;

  /// No description provided for @statAwaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Response'**
  String get statAwaitingResponse;

  /// No description provided for @statInterestedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Interested This Week'**
  String get statInterestedThisWeek;

  /// No description provided for @followUpsDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups Due'**
  String get followUpsDueTitle;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityTitle;

  /// No description provided for @noFollowUpsDue.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups due right now.'**
  String get noFollowUpsDue;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet.'**
  String get noRecentActivity;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @navBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowse;

  /// No description provided for @navInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get navInterests;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Clients'**
  String get clientsTitle;

  /// No description provided for @clientsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, phone, email'**
  String get clientsSearchHint;

  /// No description provided for @clientsFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get clientsFilterStatus;

  /// No description provided for @clientsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clientsAll;

  /// No description provided for @clientsAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get clientsAddNew;

  /// No description provided for @clientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No clients yet — add your first one.'**
  String get clientsEmpty;

  /// No description provided for @clientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get clientNameLabel;

  /// No description provided for @clientGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get clientGenderLabel;

  /// No description provided for @clientPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clientPhoneLabel;

  /// No description provided for @clientEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get clientEmailLabel;

  /// No description provided for @clientLookingForLabel.
  ///
  /// In en, this message translates to:
  /// **'Registering For'**
  String get clientLookingForLabel;

  /// No description provided for @clientSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get clientSourceLabel;

  /// No description provided for @clientStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get clientStatusLabel;

  /// No description provided for @clientNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get clientNotesLabel;

  /// No description provided for @clientFollowUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Follow-up'**
  String get clientFollowUpLabel;

  /// No description provided for @clientSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get clientSave;

  /// No description provided for @clientSaved.
  ///
  /// In en, this message translates to:
  /// **'Client saved.'**
  String get clientSaved;

  /// No description provided for @clientTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get clientTabOverview;

  /// No description provided for @clientTabRequirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get clientTabRequirements;

  /// No description provided for @clientTabShortlist.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get clientTabShortlist;

  /// No description provided for @clientTabConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get clientTabConsent;

  /// No description provided for @clientTabBatches.
  ///
  /// In en, this message translates to:
  /// **'Proposals'**
  String get clientTabBatches;

  /// No description provided for @convertToProfile.
  ///
  /// In en, this message translates to:
  /// **'Register Nikah Profile'**
  String get convertToProfile;

  /// No description provided for @profileAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'Nikah profile linked'**
  String get profileAlreadyLinked;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @requirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Matchmaking Requirements'**
  String get requirementsTitle;

  /// No description provided for @requirementsAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Requirement'**
  String get requirementsAddItem;

  /// No description provided for @requirementTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get requirementTypeLabel;

  /// No description provided for @requirementValueLabel.
  ///
  /// In en, this message translates to:
  /// **'What they want'**
  String get requirementValueLabel;

  /// No description provided for @requirementPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get requirementPriorityLabel;

  /// No description provided for @requirementsSaved.
  ///
  /// In en, this message translates to:
  /// **'Requirements saved.'**
  String get requirementsSaved;

  /// No description provided for @shortlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlistTitle;

  /// No description provided for @shortlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'No candidates shortlisted yet.'**
  String get shortlistEmpty;

  /// No description provided for @shortlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to Shortlist'**
  String get shortlistAdd;

  /// No description provided for @shortlistRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get shortlistRemove;

  /// No description provided for @shortlistNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get shortlistNoteLabel;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consentTitle;

  /// No description provided for @consentRecord.
  ///
  /// In en, this message translates to:
  /// **'Record Consent'**
  String get consentRecord;

  /// No description provided for @consentRequest.
  ///
  /// In en, this message translates to:
  /// **'Request via Link'**
  String get consentRequest;

  /// No description provided for @consentRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get consentRevoke;

  /// No description provided for @consentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Consent Type'**
  String get consentTypeLabel;

  /// No description provided for @consentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'How Obtained'**
  String get consentMethodLabel;

  /// No description provided for @consentActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get consentActive;

  /// No description provided for @consentRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get consentRevoked;

  /// No description provided for @consentPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting on client'**
  String get consentPending;

  /// No description provided for @progressLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Link'**
  String get progressLinkTitle;

  /// No description provided for @progressLinkGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate / Regenerate Link'**
  String get progressLinkGenerate;

  /// No description provided for @progressLinkShare.
  ///
  /// In en, this message translates to:
  /// **'Share with Client'**
  String get progressLinkShare;

  /// No description provided for @progressLinkExplain.
  ///
  /// In en, this message translates to:
  /// **'The client unlocks this page with the last 7 digits of their phone number.'**
  String get progressLinkExplain;

  /// No description provided for @batchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Proposal Batches'**
  String get batchesTitle;

  /// No description provided for @batchesNew.
  ///
  /// In en, this message translates to:
  /// **'New Batch'**
  String get batchesNew;

  /// No description provided for @batchAddCandidate.
  ///
  /// In en, this message translates to:
  /// **'Add Candidate'**
  String get batchAddCandidate;

  /// No description provided for @batchSend.
  ///
  /// In en, this message translates to:
  /// **'Send Batch'**
  String get batchSend;

  /// No description provided for @batchStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get batchStatusDraft;

  /// No description provided for @batchStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get batchStatusSent;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @regenerateLink.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Link'**
  String get regenerateLink;

  /// No description provided for @walkInWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Nikah Profile'**
  String get walkInWizardTitle;

  /// No description provided for @walkInStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get walkInStepAccount;

  /// No description provided for @walkInStepBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic Details'**
  String get walkInStepBasic;

  /// No description provided for @walkInStepFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get walkInStepFamily;

  /// No description provided for @walkInStepDeen.
  ///
  /// In en, this message translates to:
  /// **'Religious Practice'**
  String get walkInStepDeen;

  /// No description provided for @walkInStepAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get walkInStepAbout;

  /// No description provided for @walkInStepVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get walkInStepVerification;

  /// No description provided for @walkInStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get walkInStepPayment;

  /// No description provided for @walkInIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Client\'s Email or Phone (for their login)'**
  String get walkInIdentifierLabel;

  /// No description provided for @walkInDateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get walkInDateOfBirthLabel;

  /// No description provided for @walkInCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get walkInCityLabel;

  /// No description provided for @walkInGuardianNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian Name'**
  String get walkInGuardianNameLabel;

  /// No description provided for @walkInGuardianContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Guardian Contact'**
  String get walkInGuardianContactLabel;

  /// No description provided for @walkInCnicNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'CNIC Number'**
  String get walkInCnicNumberLabel;

  /// No description provided for @walkInCnicFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'CNIC Front Photo'**
  String get walkInCnicFrontLabel;

  /// No description provided for @walkInCnicBackLabel.
  ///
  /// In en, this message translates to:
  /// **'CNIC Back Photo'**
  String get walkInCnicBackLabel;

  /// No description provided for @walkInPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get walkInPhotoLabel;

  /// No description provided for @walkInSaveStep.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get walkInSaveStep;

  /// No description provided for @walkInFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get walkInFinish;

  /// No description provided for @walkInPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get walkInPaymentMethodLabel;

  /// No description provided for @walkInPaymentReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference (optional)'**
  String get walkInPaymentReferenceLabel;

  /// No description provided for @walkInPaymentScreenshotLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Screenshot'**
  String get walkInPaymentScreenshotLabel;

  /// No description provided for @walkInSubmitPayment.
  ///
  /// In en, this message translates to:
  /// **'Submit Payment'**
  String get walkInSubmitPayment;

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Profiles'**
  String get browseTitle;

  /// No description provided for @browseFilterGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get browseFilterGender;

  /// No description provided for @browseFilterCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get browseFilterCity;

  /// No description provided for @browseFilterSect.
  ///
  /// In en, this message translates to:
  /// **'Sect'**
  String get browseFilterSect;

  /// No description provided for @browseFilterMaritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get browseFilterMaritalStatus;

  /// No description provided for @browseRequestContact.
  ///
  /// In en, this message translates to:
  /// **'Request Contact Details'**
  String get browseRequestContact;

  /// No description provided for @browseRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Contact request sent to admin for review.'**
  String get browseRequestSent;

  /// No description provided for @browseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No profiles match these filters.'**
  String get browseEmpty;

  /// No description provided for @interestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mutual Interest Inbox'**
  String get interestsTitle;

  /// No description provided for @interestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending interests right now.'**
  String get interestsEmpty;

  /// No description provided for @interestAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get interestAccept;

  /// No description provided for @interestDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get interestDecline;

  /// No description provided for @commissionTitle.
  ///
  /// In en, this message translates to:
  /// **'My Commission'**
  String get commissionTitle;

  /// No description provided for @commissionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get commissionPending;

  /// No description provided for @commissionApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get commissionApproved;

  /// No description provided for @commissionPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get commissionPaid;

  /// No description provided for @commissionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No commission entries yet.'**
  String get commissionEmpty;

  /// No description provided for @commissionFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get commissionFlagged;

  /// No description provided for @performanceTitle.
  ///
  /// In en, this message translates to:
  /// **'My Performance'**
  String get performanceTitle;

  /// No description provided for @performanceQualityScore.
  ///
  /// In en, this message translates to:
  /// **'Quality Score'**
  String get performanceQualityScore;

  /// No description provided for @performanceVerificationRate.
  ///
  /// In en, this message translates to:
  /// **'Verification Rate'**
  String get performanceVerificationRate;

  /// No description provided for @performancePaidConversion.
  ///
  /// In en, this message translates to:
  /// **'Paid Conversion'**
  String get performancePaidConversion;

  /// No description provided for @performanceCompliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get performanceCompliance;

  /// No description provided for @performanceCommissionEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Commission Earned'**
  String get performanceCommissionEarned;

  /// No description provided for @performanceNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level: {level}'**
  String performanceNextLevel(String level);

  /// No description provided for @performanceMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the top level 🎉'**
  String get performanceMaxLevel;

  /// No description provided for @performanceVerifiedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Verified profiles'**
  String get performanceVerifiedProfiles;

  /// No description provided for @performanceDaysAsCounselor.
  ///
  /// In en, this message translates to:
  /// **'Days as counselor'**
  String get performanceDaysAsCounselor;

  /// No description provided for @performanceCommissionByLevel.
  ///
  /// In en, this message translates to:
  /// **'Commission by Level'**
  String get performanceCommissionByLevel;

  /// No description provided for @performanceCommissionByLevelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified-profile commission rate — set by admin, updates automatically as you level up.'**
  String get performanceCommissionByLevelSubtitle;

  /// No description provided for @performanceCurrentLevelTag.
  ///
  /// In en, this message translates to:
  /// **'Your level'**
  String get performanceCurrentLevelTag;

  /// No description provided for @referralTitle.
  ///
  /// In en, this message translates to:
  /// **'My Referral'**
  String get referralTitle;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Counselor Code'**
  String get referralCode;

  /// No description provided for @referralLink.
  ///
  /// In en, this message translates to:
  /// **'Referral Link'**
  String get referralLink;

  /// No description provided for @referralCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get referralCopy;

  /// No description provided for @referralShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get referralShare;

  /// No description provided for @referralCount.
  ///
  /// In en, this message translates to:
  /// **'Referred Registrations'**
  String get referralCount;

  /// No description provided for @applicationTitle.
  ///
  /// In en, this message translates to:
  /// **'My Certification'**
  String get applicationTitle;

  /// No description provided for @applicationLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get applicationLevel;

  /// No description provided for @applicationCounselorCode.
  ///
  /// In en, this message translates to:
  /// **'Counselor ID'**
  String get applicationCounselorCode;

  /// No description provided for @applicationAgreementAccepted.
  ///
  /// In en, this message translates to:
  /// **'Agreement & NDA Accepted'**
  String get applicationAgreementAccepted;

  /// No description provided for @applicationNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Not yet accepted'**
  String get applicationNotAccepted;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your internet connection.'**
  String get errorNetwork;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up — nothing needs your attention right now.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsFollowUpsSection.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups Due'**
  String get notificationsFollowUpsSection;

  /// No description provided for @notificationsActivitySection.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get notificationsActivitySection;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'Nikah Counselor Guide'**
  String get guideTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
