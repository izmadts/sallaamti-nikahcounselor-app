// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sallaamti Nikah Counselor';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get english => 'English';

  @override
  String get urdu => 'اردو';

  @override
  String get continueLabel => 'Continue';

  @override
  String get loginTitle => 'Nikah Counselor Login';

  @override
  String get loginSubtitle =>
      'Sign in with the credentials you were given when you were certified.';

  @override
  String get emailOrPhone => 'Email or Phone';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get notCounselorAccount =>
      'This account isn\'t a Nikah Counselor account. Contact Sallaamti if you believe this is a mistake.';

  @override
  String get logout => 'Log Out';

  @override
  String get noAccountYet => 'Not a counselor yet?';

  @override
  String get applyHere => 'Apply Here';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordIntro =>
      'Enter the email address on your counselor account and we\'ll send you a 6-digit reset code.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String resetCodeSentTo(String email) {
    return 'We\'ve sent a 6-digit code to $email, if that address is registered. It expires in 10 minutes.';
  }

  @override
  String get resetCode => 'Reset Code';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordsDoNotMatch => 'Those passwords don\'t match.';

  @override
  String get passwordTooShort => 'Use at least 8 characters.';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get backToLogin => 'Back to log in';

  @override
  String get useADifferentEmail => 'Use a different email';

  @override
  String get applyTitle => 'Become a Nikah Counselor';

  @override
  String get applySubtitle =>
      'Fill this out and our team will review your application. Once approved and certified, you\'ll be able to log in and start working.';

  @override
  String get applyWhatsappLabel => 'WhatsApp Number (if different)';

  @override
  String get applyAgeLabel => 'Age';

  @override
  String get applyMaritalStatusLabel => 'Marital Status';

  @override
  String get applyQualificationLabel => 'Qualification';

  @override
  String get applySelfieLabel => 'Selfie Photo';

  @override
  String get applyAreaLabel => 'Area';

  @override
  String get applyAddressLabel => 'Address';

  @override
  String get applyPayoutTitle => 'Commission Payout Details (optional)';

  @override
  String get applyPayoutSubtitle =>
      'You can add this later too — only needed once you start earning commission.';

  @override
  String get applyPayoutTitleLabel => 'Account Title';

  @override
  String get applyPayoutNumberLabel => 'Account / Mobile Number';

  @override
  String get applyPayoutBankLabel => 'Bank Name';

  @override
  String get applyConsentText =>
      'I consent to Sallaamti verifying my identity and processing my application.';

  @override
  String get applyTermsText =>
      'I agree to the Nikah Counselor terms and code of conduct.';

  @override
  String get applyConsentRequired =>
      'Please accept both checkboxes to continue.';

  @override
  String get applyPhotosRequired => 'Please add your selfie photo.';

  @override
  String get applySubmit => 'Submit Application';

  @override
  String get applySubmitted =>
      'Thank you! Your application has been received — our team will review it and be in touch soon.';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get statNewLeads => 'New Leads';

  @override
  String get statFollowUpsDue => 'Follow-ups Due';

  @override
  String get statRegistered => 'Registered';

  @override
  String get statActiveBatches => 'Active Batches';

  @override
  String get statAwaitingResponse => 'Awaiting Response';

  @override
  String get statInterestedThisWeek => 'Interested This Week';

  @override
  String get followUpsDueTitle => 'Follow-ups Due';

  @override
  String get recentActivityTitle => 'Recent Activity';

  @override
  String get noFollowUpsDue => 'No follow-ups due right now.';

  @override
  String get noRecentActivity => 'No activity yet.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navClients => 'Clients';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navInterests => 'Interests';

  @override
  String get navMore => 'More';

  @override
  String get clientsTitle => 'My Clients';

  @override
  String get clientsSearchHint => 'Search name, phone, email';

  @override
  String get clientsFilterStatus => 'Status';

  @override
  String get clientsAll => 'All';

  @override
  String get clientsAddNew => 'Add Client';

  @override
  String get clientsEmpty => 'No clients yet — add your first one.';

  @override
  String get clientNameLabel => 'Full Name';

  @override
  String get clientGenderLabel => 'Gender';

  @override
  String get clientPhoneLabel => 'Phone';

  @override
  String get clientEmailLabel => 'Email';

  @override
  String get clientLookingForLabel => 'Registering For';

  @override
  String get clientSourceLabel => 'Source';

  @override
  String get clientStatusLabel => 'Status';

  @override
  String get clientNotesLabel => 'Notes';

  @override
  String get clientFollowUpLabel => 'Next Follow-up';

  @override
  String get clientSave => 'Save';

  @override
  String get clientSaved => 'Client saved.';

  @override
  String get clientTabOverview => 'Overview';

  @override
  String get clientTabRequirements => 'Requirements';

  @override
  String get clientTabShortlist => 'Shortlist';

  @override
  String get clientTabConsent => 'Consent';

  @override
  String get clientTabBatches => 'Proposals';

  @override
  String get convertToProfile => 'Register Nikah Profile';

  @override
  String get profileAlreadyLinked => 'Nikah profile linked';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get requirementsTitle => 'Matchmaking Requirements';

  @override
  String get requirementsAddItem => 'Add Requirement';

  @override
  String get requirementTypeLabel => 'Type';

  @override
  String get requirementValueLabel => 'What they want';

  @override
  String get requirementPriorityLabel => 'Priority';

  @override
  String get requirementsSaved => 'Requirements saved.';

  @override
  String get shortlistTitle => 'Shortlist';

  @override
  String get shortlistEmpty => 'No candidates shortlisted yet.';

  @override
  String get shortlistAdd => 'Add to Shortlist';

  @override
  String get shortlistRemove => 'Remove';

  @override
  String get shortlistNoteLabel => 'Note (optional)';

  @override
  String get consentTitle => 'Consent';

  @override
  String get consentRecord => 'Record Consent';

  @override
  String get consentRequest => 'Request via Link';

  @override
  String get consentRevoke => 'Revoke';

  @override
  String get consentTypeLabel => 'Consent Type';

  @override
  String get consentMethodLabel => 'How Obtained';

  @override
  String get consentActive => 'Active';

  @override
  String get consentRevoked => 'Revoked';

  @override
  String get consentPending => 'Waiting on client';

  @override
  String get progressLinkTitle => 'Progress Link';

  @override
  String get progressLinkGenerate => 'Generate / Regenerate Link';

  @override
  String get progressLinkShare => 'Share with Client';

  @override
  String get progressLinkExplain =>
      'The client unlocks this page with the last 7 digits of their phone number.';

  @override
  String get loginPasswordTitle => 'Client Login Password';

  @override
  String get loginPasswordExplain =>
      'Set a temporary password so this client can log into the Sallaamti app themselves. They\'ll be prompted to choose their own on first login.';

  @override
  String get loginPasswordSet => 'Set Login Password';

  @override
  String get loginPasswordFieldLabel => 'Temporary Password';

  @override
  String get loginPasswordGenerateButton => 'Generate Strong Password';

  @override
  String get loginPasswordCopyButton => 'Copy';

  @override
  String get loginPasswordCopied => 'Copied to clipboard';

  @override
  String get loginPasswordConfirmButton => 'Set Password';

  @override
  String get loginPasswordSuccess =>
      'Password set — share it with the client now.';

  @override
  String get batchesTitle => 'Proposal Batches';

  @override
  String get batchesNew => 'New Batch';

  @override
  String get batchAddCandidate => 'Add Candidate';

  @override
  String get batchSend => 'Send Batch';

  @override
  String get batchStatusDraft => 'Draft';

  @override
  String get batchStatusSent => 'Sent';

  @override
  String get shareLink => 'Share Link';

  @override
  String get regenerateLink => 'Regenerate Link';

  @override
  String get walkInWizardTitle => 'Register Nikah Profile';

  @override
  String get walkInStepAccount => 'Account';

  @override
  String get walkInStepBasic => 'Basic Details';

  @override
  String get walkInStepFamily => 'Family';

  @override
  String get walkInStepDeen => 'Religious Practice';

  @override
  String get walkInStepAbout => 'About';

  @override
  String get walkInStepPayment => 'Payment';

  @override
  String get walkInIdentifierLabel =>
      'Client\'s Email or Phone (for their login)';

  @override
  String get walkInDateOfBirthLabel => 'Date of Birth';

  @override
  String get walkInCityLabel => 'City';

  @override
  String get walkInGuardianNameLabel => 'Guardian Name';

  @override
  String get walkInGuardianContactLabel => 'Guardian Contact';

  @override
  String get walkInCnicNumberLabel => 'CNIC Number';

  @override
  String get walkInCnicFrontLabel => 'CNIC Front Photo';

  @override
  String get walkInCnicBackLabel => 'CNIC Back Photo';

  @override
  String get walkInSaveStep => 'Save & Continue';

  @override
  String get walkInFinish => 'Finish';

  @override
  String get walkInPaymentMethodLabel => 'Payment Method';

  @override
  String get walkInPaymentReferenceLabel => 'Reference (optional)';

  @override
  String get walkInPaymentScreenshotLabel => 'Payment Screenshot';

  @override
  String get walkInSubmitPayment => 'Submit Payment';

  @override
  String get browseTitle => 'Browse Profiles';

  @override
  String get browseFilterGender => 'Gender';

  @override
  String get browseFilterCity => 'City';

  @override
  String get browseFilterSect => 'Sect';

  @override
  String get browseFilterMaritalStatus => 'Marital Status';

  @override
  String get browseRequestContact => 'Request Contact Details';

  @override
  String get browseRequestSent => 'Contact request sent to admin for review.';

  @override
  String get browseEmpty => 'No profiles match these filters.';

  @override
  String get interestsTitle => 'Mutual Interest Inbox';

  @override
  String get interestsEmpty => 'No pending interests right now.';

  @override
  String get interestAccept => 'Accept';

  @override
  String get interestDecline => 'Decline';

  @override
  String get commissionTitle => 'My Commission';

  @override
  String get commissionPending => 'Pending';

  @override
  String get commissionApproved => 'Approved';

  @override
  String get commissionPaid => 'Paid';

  @override
  String get commissionEmpty => 'No commission entries yet.';

  @override
  String get commissionFlagged => 'Flagged';

  @override
  String get performanceTitle => 'My Performance';

  @override
  String get performanceQualityScore => 'Quality Score';

  @override
  String get performanceVerificationRate => 'Verification Rate';

  @override
  String get performancePaidConversion => 'Paid Conversion';

  @override
  String get performanceCompliance => 'Compliance';

  @override
  String get performanceCommissionEarned => 'Total Commission Earned';

  @override
  String performanceNextLevel(String level) {
    return 'Next Level: $level';
  }

  @override
  String get performanceMaxLevel => 'You\'ve reached the top level 🎉';

  @override
  String get performanceVerifiedProfiles => 'Verified profiles';

  @override
  String get performanceDaysAsCounselor => 'Days as counselor';

  @override
  String get performanceCommissionByLevel => 'Commission by Level';

  @override
  String get performanceCommissionByLevelSubtitle =>
      'Verified-profile commission rate — set by admin, updates automatically as you level up.';

  @override
  String get performanceCurrentLevelTag => 'Your level';

  @override
  String get performanceNotCertifiedYet =>
      'Your Nikah Counselor certification isn\'t on file yet — contact your admin if this looks wrong.';

  @override
  String get referralTitle => 'My Referral';

  @override
  String get referralCode => 'Counselor Code';

  @override
  String get referralLink => 'Referral Link';

  @override
  String get referralCopy => 'Copy Link';

  @override
  String get referralShare => 'Share';

  @override
  String get referralCount => 'Referred Registrations';

  @override
  String get applicationTitle => 'My Certification';

  @override
  String get applicationLevel => 'Level';

  @override
  String get applicationCounselorCode => 'Counselor ID';

  @override
  String get applicationAgreementAccepted => 'Agreement & NDA Accepted';

  @override
  String get applicationNotAccepted => 'Not yet accepted';

  @override
  String get certificateTitle => 'Nikah Counselor ID Card';

  @override
  String get certificateDownload => 'Download Certificate PDF';

  @override
  String get certificateCardSectionTitle => 'Physical Card';

  @override
  String certificateCardRequested(String date) {
    return 'Requested $date — admin will print and mail it';
  }

  @override
  String certificateCardDispatched(String date) {
    return 'Dispatched $date';
  }

  @override
  String get certificateRequestCard => 'Request Card Dispatch';

  @override
  String get paymentAccountsTitle => 'Sallaamti Bank Accounts';

  @override
  String get paymentAccountsSubtitle =>
      'Share these with a client paying by JazzCash, EasyPaisa, or bank transfer.';

  @override
  String get paymentAccountsCopied => 'Copied to clipboard';

  @override
  String get paymentAccountsEmpty => 'No payment accounts are configured yet.';

  @override
  String get packagesTitle => 'Nikah Packages';

  @override
  String get packagesSubtitle =>
      'The current packages and what each one includes — same details a client sees when choosing one.';

  @override
  String get packagesEmpty => 'No packages are configured yet.';

  @override
  String get packagesOneTime => 'One-time';

  @override
  String packagesDays(int count) {
    return '$count days';
  }

  @override
  String get packagesUnlimitedProposals => 'Unlimited proposals';

  @override
  String packagesProposalLimit(int count) {
    return '$count proposals';
  }

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Couldn\'t connect. Check your internet connection.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading…';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty =>
      'You\'re all caught up — nothing needs your attention right now.';

  @override
  String get notificationsFollowUpsSection => 'Follow-ups Due';

  @override
  String get notificationsActivitySection => 'Recent Activity';

  @override
  String get guideTitle => 'Nikah Counselor Guide';
}
