// This app's own reference guide — kept in sync with its actual screens
// (Dashboard/Clients/Browse/Interests/More, and each client's Overview/
// Requirements/Shortlist/Consent/Proposals/Messages tabs), not with the web
// matchmaker panel's separate "one secure link" workflow (see guide/
// partials/matchmaker.blade.php on the website — a different system this
// app doesn't use). **word** renders bold; a paragraph starting with "• "
// renders as a bullet.
class GuideSection {
  final String title;
  final List<String> paragraphs;
  const GuideSection({required this.title, required this.paragraphs});
}

class GuideContent {
  static List<GuideSection> forLocale(String languageCode) => languageCode == 'ur' ? _ur : _en;

  static const _en = <GuideSection>[
    GuideSection(title: 'Your Role', paragraphs: [
      'As a Nikah Counselor, you help connect families on Sallaamti — capturing leads from WhatsApp/Facebook/Instagram, helping them register, understanding what they\'re actually looking for, and putting together proposals for candidates who genuinely fit.',
      'This app is your own workspace — everything in it is scoped to the clients assigned to you.',
    ]),
    GuideSection(title: 'Privacy & Security — Read This First', paragraphs: [
      'These aren\'t formalities — they\'re what makes clients trust the system enough to use it.',
      '• **CNIC, photos, and direct contact details are never shown to you.** You work from age, city, education, profession, and other profile fields — never CNIC images or a phone/email. Use **Request Contact** on a candidate\'s profile and let admin approve and facilitate an introduction.',
      '• **A client\'s own phone number is also never shown on your screens.** You communicate with them through the in-app **Messages** tab on their client page, or over WhatsApp/phone using the number they gave you when you added them — never through documents you collect yourself.',
      '• **Never contact a family directly outside the system.** Even once you know a name or general area, don\'t reach out yourself — that\'s what Request Contact and admin approval exist for.',
      '• **Requirements notes are working notes, not private chat.** Keep the language plain and respectful — describe what someone is looking for, not judgments about people.',
      '• **Some profiles won\'t show up when you search — that\'s intentional.** "Confidential" profiles are hidden from search/browse entirely, even from you. You can only work with one if it\'s already linked to a client you\'re handling.',
    ]),
    GuideSection(title: 'Your Dashboard, Explained', paragraphs: [
      'Logging in takes you straight to your own dashboard.',
      '• **New Leads / Registered** — where your assigned clients currently stand.',
      '• **Follow-ups Due** — clients with a follow-up date that\'s arrived — check this first each day.',
      '• **Active Batches** — proposal batches you\'ve sent that are still waiting on a full response.',
      '• **Awaiting Response** — individual candidates you\'ve sent that the client hasn\'t replied to yet.',
      '• **Interested This Week** — a quick pulse on recent positive responses.',
      'Your avatar in the top bar carries a small badge showing your current level (🥉 Nikah Counselor → 🥈 Certified → 🥇 Senior → ⭐ Regional Coordinator) — tap it any time to open **My Performance**.',
      'The bottom bar covers everything: **Dashboard**, **Clients**, **Browse**, **Interests** (candidates who liked one of your clients\' profiles — accept or decline on the client\'s behalf), and **More** (Commission, Performance, Referral, Certification, Logout).',
    ]),
    GuideSection(title: 'Step 1 — Add a Client', paragraphs: [
      'Most real leads arrive over WhatsApp or a Facebook/Instagram ad and never register themselves. Press **Add Client** and record their name, phone/email, gender, and source — they\'re assigned to you automatically.',
      'Update their **Status** as things move (New → Contacted → Interested → Registered, or Not Interested/Closed), and set a **Next Follow-up** date so it surfaces on your dashboard.',
      'Once they have a linked Nikah profile, their client page\'s Overview tab shows whether they\'re actually **using the member app** — green "Active in Member App" with a last-seen time, or grey "Not using the Member App" if there\'s nothing recent. If they\'re not active in-app, keep relying on WhatsApp/phone — in-app messages won\'t reach them yet.',
    ]),
    GuideSection(title: 'Step 2 — Capture Requirements', paragraphs: [
      'On a client\'s page, open the **Requirements** tab — the same fields the admin/web profile wizard uses for Partner Preferences: Minimum/Maximum Age, Preferred City, Sect, Education, Marital Status, Income, and Other Preferences. All optional — fill in whatever the client has actually told you.',
      'This isn\'t shown to the client; it\'s what the **Shortlist** tab automatically filters by once you save it.',
    ]),
    GuideSection(title: 'Step 3 — Build a Shortlist', paragraphs: [
      'In the **Shortlist** tab, press **+ Add to Shortlist** to search verified profiles. If you\'ve already saved Requirements, the city/age/sect/etc. filters are pre-applied for you automatically — you can still adjust or clear them.',
      'Each candidate you add appears here with its match score. From here you can:',
      '• **Share on WhatsApp** — copies the candidate\'s details (age, city, sect, education, profession, marital status, height — never anything identity-revealing) so you can paste it straight into your chat with the client.',
      '• **Mark Final** — once the client confirms they like this candidate (over WhatsApp, a call, in person), this records their consent, moves the candidate straight into **Proposals**, sets a 7-day follow-up automatically, and removes it from the shortlist — one action instead of three separate steps.',
    ]),
    GuideSection(title: 'Step 4 — Consent (if you need it separately)', paragraphs: [
      '**Mark Final** already records consent for you automatically the first time you use it for a client. If you need to record or request consent on its own — before finalizing any specific candidate — open the **Consent** tab: **Record Consent** for one you already got verbally/by phone/in person, or **Request via Link** to ask the client to confirm it themselves. To withdraw a consent, open it and revoke — the original record stays, nothing is deleted.',
    ]),
    GuideSection(title: 'Step 5 — Package Payment', paragraphs: [
      'A client\'s matchmaking package and its payment status show on their Overview tab — pick one for them if they haven\'t, or submit a payment receipt on their behalf if they paid you directly. Either way, only admin confirms a payment as final.',
    ]),
    GuideSection(title: 'Proposals — Where Finalized Candidates Land', paragraphs: [
      'The **Proposals** tab shows every batch you\'ve sent. Once the client responds **interested** to any candidate (through their own account, or recorded for them via Mark Final), a prominent **💍 Final Match** card appears at the top — that\'s the headline result for this client.',
      'You can still manage batches manually below it: **New Batch**, **Add Candidate** (up to 5 per batch), and **Send Batch** — useful if you\'re proposing more than one candidate before narrowing down.',
    ]),
    GuideSection(title: 'Step 6 — Registering a New Client', paragraphs: [
      'If someone\'s ready to register, open their client page and press **Register Nikah Profile** — this opens the walk-in wizard with their name and phone/email already filled in.',
    ]),
    GuideSection(title: 'Staying in Touch', paragraphs: [
      'Each client page has a **Messages** tab — a private, moderated conversation with that client, same as what they see under "My Counselor" in their own member app, if they\'re using it (see the app-activity note in Step 1). If they\'re not, keep using WhatsApp/phone with the number on file for them.',
      'Need a candidate\'s guardian contact shared for an introduction? Open that candidate\'s profile from Browse and press **Request Contact** — admin reviews and approves it, and it\'s tracked against the right client automatically if you opened it from that client\'s pick-a-candidate flow.',
    ]),
    GuideSection(title: 'Collecting Their Verification Fee Payment', paragraphs: [
      'If a fee applies and your client pays you directly, get the complete document set — CNIC photos and payment receipt — into the system together. Two ways: during registration (the wizard\'s Payment step), or afterward from the client\'s linked Nikah profile.',
      'Either way, this only submits proof for admin to confirm — it doesn\'t mark the fee as paid on its own.',
    ]),
    GuideSection(title: 'Reading the Activity Timeline', paragraphs: [
      'Every meaningful action — lead received, status change, profile linked, requirements saved, candidate shortlisted, candidate finalized, consent recorded, batch sent, client response, payment submitted/confirmed — logs automatically. Use it to pick up a client\'s history at a glance.',
    ]),
    GuideSection(title: 'Your Level & Performance', paragraphs: [
      'Tap your avatar (or open **My Performance**) to see your Quality Score — built from Verification Rate, Paid Conversion Rate, and Compliance — plus a real progress breakdown toward your next level: exactly how many more verified profiles, how much quality score, and how many more days you need.',
      'Levels are promoted automatically once you clear all three for a level — nothing to request. **Higher levels earn a higher commission rate on every sale** — see the Commission by Level table on your Performance page for the exact current rates.',
    ]),
    GuideSection(title: 'What\'s Outside Your Access', paragraphs: [
      'Approving/rejecting profiles, **confirming** a submitted verification or package payment (you can submit proof, but only admin confirms it), viewing CNIC images or a client\'s real phone number, and reviewing safety reports need the full Admin role. Flag anything that needs that level of action to an admin.',
    ]),
    GuideSection(title: 'Quick Checklist', paragraphs: [
      '• New lead comes in → **Add Client**, set a follow-up date.',
      '• Understand what they want → fill in **Requirements**.',
      '• Find candidates → **Shortlist** tab, **+ Add to Shortlist** (auto-filtered from Requirements).',
      '• Client likes one → **Mark Final** on it — records consent, moves it to Proposals, sets a 7-day follow-up, all at once.',
      '• Want to share a profile first? Use **Share on WhatsApp** on the shortlist item.',
      '• Client responded interested → check the **💍 Final Match** card at the top of Proposals.',
      '• Need an intro facilitated? **Request Contact** on the candidate\'s profile from Browse.',
      '• Not sure if they\'ll see an in-app message? Check the **app-activity badge** on their Overview tab.',
    ]),
  ];

  static const _ur = <GuideSection>[
    GuideSection(title: 'آپ کا کردار', paragraphs: [
      'ایک نکاح مشیر کے طور پر، آپ سلامتی پر خاندانوں کو جوڑنے میں مدد کرتے ہیں — واٹس ایپ/فیس بک/انسٹاگرام سے لیڈز حاصل کرنا، رجسٹریشن میں مدد، یہ سمجھنا کہ وہ اصل میں کیا تلاش کر رہے ہیں، اور موزوں امیدواروں کے لیے تجاویز تیار کرنا۔',
      'یہ ایپ آپ کا اپنا ورک اسپیس ہے — اس میں جو کچھ بھی ہے وہ صرف آپ کو تفویض کردہ کلائنٹس تک محدود ہے۔',
    ]),
    GuideSection(title: 'رازداری اور سیکیورٹی — یہ پہلے پڑھیں', paragraphs: [
      'یہ محض رسمی باتیں نہیں — یہی وہ چیزیں ہیں جو کلائنٹس کو نظام پر اعتماد کے قابل بناتی ہیں۔',
      '• **شناختی کارڈ، تصاویر، اور رابطہ کی تفصیلات آپ کو کبھی نہیں دکھائی جاتیں۔** عمر، شہر، تعلیم، پیشہ جیسی تفصیلات سے کام لیں — کبھی CNIC یا فون/ای میل نہیں۔ تعارف کے لیے کسی امیدوار کی پروفائل پر **رابطے کی درخواست** استعمال کریں۔',
      '• **کلائنٹ کا اپنا موبائل نمبر بھی آپ کی سکرین پر کبھی نہیں دکھایا جاتا۔** آپ ان سے کلائنٹ کے صفحے پر موجود **پیغامات** ٹیب کے ذریعے، یا کلائنٹ شامل کرتے وقت دیے گئے نمبر پر واٹس ایپ/فون کے ذریعے رابطہ کرتے ہیں — کبھی خود جمع کیے گئے دستاویزات سے نہیں۔',
      '• **نظام سے باہر کبھی براہ راست رابطہ نہ کریں۔** رابطے کی درخواست اور ایڈمن کی منظوری کا نظام موجود ہے۔',
      '• **ضروریات کے نوٹس کام کے نوٹس ہیں، نجی چیٹ نہیں۔** زبان سادہ اور باوقار رکھیں۔',
      '• **کچھ پروفائلز تلاش میں نظر نہیں آئیں گی — یہ جان بوجھ کر ہے۔** "خفیہ" پروفائلز آپ سے بھی پوشیدہ ہوتی ہیں، سوائے اس کے کہ پہلے سے آپ کے کسی کلائنٹ سے منسلک ہوں۔',
    ]),
    GuideSection(title: 'آپ کا ڈیش بورڈ سمجھیں', paragraphs: [
      'لاگ اِن کرنے پر آپ براہ راست اپنے ڈیش بورڈ پر پہنچتے ہیں۔',
      '• **نئی لیڈز / رجسٹرڈ** — آپ کے کلائنٹس اس وقت کہاں کھڑے ہیں۔',
      '• **فالو اپ باقی** — جن کلائنٹس کی فالو اپ تاریخ آ چکی ہے — ہر روز سب سے پہلے یہ دیکھیں۔',
      '• **فعال بیچز** — بھیجے گئے بیچز جن کا مکمل جواب باقی ہے۔',
      '• **جواب کا انتظار** — بھیجے گئے امیدوار جن کا جواب نہیں آیا۔',
      '• **اس ہفتے دلچسپی** — حالیہ مثبت جوابات پر ایک نظر۔',
      'اوپر بار میں آپ کی تصویر پر آپ کی موجودہ سطح کا چھوٹا نشان ہوتا ہے (🥉 → 🥈 → 🥇 → ⭐) — کسی بھی وقت **میری کارکردگی** کھولنے کے لیے دبائیں۔',
      'نیچے کا بار سب کچھ دیتا ہے: **ڈیش بورڈ**، **کلائنٹس**، **براؤز**، **دلچسپی** (وہ امیدوار جنہوں نے آپ کے کسی کلائنٹ کی پروفائل پسند کی — کلائنٹ کی طرف سے قبول یا رد کریں)، اور **مزید** (کمیشن، کارکردگی، ریفرل، سرٹیفیکیشن، لاگ آؤٹ)۔',
    ]),
    GuideSection(title: 'مرحلہ 1 — کلائنٹ شامل کریں', paragraphs: [
      'زیادہ تر لیڈز واٹس ایپ یا فیس بک/انسٹاگرام سے آتی ہیں اور خود رجسٹر نہیں ہوتیں۔ **کلائنٹ شامل کریں** دبائیں اور نام، فون/ای میل، جنس، ذریعہ درج کریں — وہ خودکار طور پر آپ کو تفویض ہوں گے۔',
      '**حیثیت** اپ ڈیٹ کرتے رہیں اور **اگلا فالو اپ** تاریخ مقرر کریں۔',
      'جب ان کی نکاح پروفائل منسلک ہو جائے، تو ان کے صفحے کے خلاصہ ٹیب پر نظر آئے گا کہ کیا وہ واقعی **ممبر ایپ استعمال کر رہے ہیں** — سبز "ممبر ایپ میں فعال" آخری وقت کے ساتھ، یا سرمئی "ممبر ایپ استعمال نہیں کر رہے" اگر کچھ حالیہ نہیں۔ اگر وہ ایپ میں فعال نہیں تو واٹس ایپ/فون پر ہی رابطہ رکھیں۔',
    ]),
    GuideSection(title: 'مرحلہ 2 — ضروریات درج کریں', paragraphs: [
      'کلائنٹ کے صفحے پر **ضروریات** ٹیب کھولیں — وہی فیلڈز جو ایڈمن/ویب پروفائل وزرڈ کی "پارٹنر ترجیحات" میں استعمال ہوتی ہیں: کم سے کم/زیادہ سے زیادہ عمر، ترجیحی شہر، فرقہ، تعلیم، ازدواجی حیثیت، آمدنی، اور دیگر ترجیحات۔ سب اختیاری ہیں — جو کلائنٹ نے بتایا ہو وہی درج کریں۔',
      'یہ کلائنٹ کو نہیں دکھایا جاتا؛ محفوظ کرتے ہی **شارٹ لسٹ** ٹیب خودکار طور پر اسی کے مطابق فلٹر کرتا ہے۔',
    ]),
    GuideSection(title: 'مرحلہ 3 — شارٹ لسٹ بنائیں', paragraphs: [
      'شارٹ لسٹ ٹیب میں **+ شارٹ لسٹ میں شامل کریں** دبائیں۔ اگر ضروریات پہلے سے محفوظ ہیں تو شہر/عمر/فرقہ وغیرہ کے فلٹرز خودکار طور پر لگ جاتے ہیں — آپ پھر بھی تبدیل یا صاف کر سکتے ہیں۔',
      'ہر شامل کردہ امیدوار یہاں میچ سکور کے ساتھ نظر آتا ہے۔ یہاں سے آپ:',
      '• **واٹس ایپ پر شیئر کریں** — امیدوار کی تفصیلات (عمر، شہر، فرقہ، تعلیم، پیشہ، ازدواجی حیثیت، قد) کاپی کر کے سیدھا کلائنٹ کی چیٹ میں پیسٹ کر سکتے ہیں۔',
      '• **حتمی قرار دیں** — جب کلائنٹ اس امیدوار کو پسند کرنے کی تصدیق کر دے، یہ رضامندی ریکارڈ کرے گا، امیدوار کو سیدھا **تجاویز** میں منتقل کرے گا، خودکار 7 دن کا فالو اپ مقرر کرے گا، اور شارٹ لسٹ سے ہٹا دے گا — ایک ہی عمل میں تین کام۔',
    ]),
    GuideSection(title: 'مرحلہ 4 — رضامندی (اگر الگ سے درکار ہو)', paragraphs: [
      '**حتمی قرار دیں** پہلی بار استعمال کرنے پر خود رضامندی ریکارڈ کر دیتا ہے۔ اگر کسی خاص امیدوار کو حتمی قرار دینے سے پہلے ہی رضامندی ریکارڈ یا درخواست کرنی ہو، تو **رضامندی** ٹیب کھولیں: پہلے سے موصول رضامندی کے لیے **رضامندی ریکارڈ کریں**، یا خود کلائنٹ سے تصدیق کروانے کے لیے **لنک کے ذریعے درخواست کریں**۔ واپس لینے کے لیے منسوخ کریں — پرانا ریکارڈ محفوظ رہتا ہے۔',
    ]),
    GuideSection(title: 'مرحلہ 5 — پیکج کی ادائیگی', paragraphs: [
      'کلائنٹ کا میچ میکنگ پیکج اور اس کی ادائیگی کی حیثیت ان کے خلاصہ ٹیب پر نظر آتی ہے — اگر ابھی نہیں لیا تو ان کے لیے منتخب کریں، یا اگر انہوں نے آپ کو براہ راست ادا کیا ہو تو رسید جمع کروائیں۔ دونوں صورتوں میں حتمی تصدیق صرف ایڈمن کرتا ہے۔',
    ]),
    GuideSection(title: 'تجاویز — حتمی امیدوار کہاں جاتے ہیں', paragraphs: [
      '**تجاویز** ٹیب میں آپ کے بھیجے ہوئے تمام بیچز نظر آتے ہیں۔ جیسے ہی کلائنٹ کسی امیدوار کو "دلچسپی" میں جواب دے (اپنے اکاؤنٹ سے، یا حتمی قرار دیے جانے کے ذریعے)، اوپر ایک نمایاں **💍 حتمی رشتہ** کارڈ نظر آتا ہے — یہی اس کلائنٹ کا اہم نتیجہ ہے۔',
      'نیچے بیچز کا دستی انتظام بھی جاری رہتا ہے: **نیا بیچ**، **امیدوار شامل کریں** (ہر بیچ میں 5 تک)، اور **بیچ بھیجیں**۔',
    ]),
    GuideSection(title: 'مرحلہ 6 — نئے کلائنٹ کی رجسٹریشن', paragraphs: [
      'اگر کوئی رجسٹریشن کے لیے تیار ہو، تو ان کا صفحہ کھولیں اور **نکاح پروفائل رجسٹر کریں** دبائیں — نام اور فون/ای میل پہلے سے بھرا ہوتا ہے۔',
    ]),
    GuideSection(title: 'رابطہ برقرار رکھنا', paragraphs: [
      'ہر کلائنٹ کے صفحے پر ایک **پیغامات** ٹیب ہوتا ہے — ایک نجی، نگرانی شدہ گفتگو، بالکل ویسی ہی جو وہ اپنے ممبر ایپ میں "میرا مشیر" کے تحت دیکھتے ہیں (اگر وہ ایپ استعمال کر رہے ہوں)۔ اگر نہیں، تو درج شدہ نمبر پر واٹس ایپ/فون استعمال کرتے رہیں۔',
      'کسی امیدوار کا سرپرست رابطہ چاہیے؟ براؤز سے اس کی پروفائل کھولیں اور **رابطے کی درخواست** دبائیں — ایڈمن جائزہ لے کر منظوری دیتا ہے، اور اگر آپ نے یہ کسی کلائنٹ کے لیے امیدوار چننے کے دوران کھولا تھا تو یہ خودکار طور پر اسی کلائنٹ سے منسلک ریکارڈ ہوتی ہے۔',
    ]),
    GuideSection(title: 'تصدیقی فیس کی ادائیگی وصول کرنا', paragraphs: [
      'اگر فیس لاگو ہو اور کلائنٹ آپ کو براہ راست ادا کرے، تو CNIC اور رسید ایک ساتھ داخل کریں — رجسٹریشن کے دوران یا بعد میں پروفائل سے۔',
      'یہ صرف ایڈمن کی تصدیق کے لیے ثبوت جمع کرواتا ہے۔',
    ]),
    GuideSection(title: 'سرگرمی کی ٹائم لائن', paragraphs: [
      'ہر اہم عمل — لیڈ موصول ہونا، حیثیت کی تبدیلی، پروفائل کا منسلک ہونا، ضروریات محفوظ ہونا، امیدوار کا شارٹ لسٹ ہونا، حتمی قرار پانا، رضامندی ریکارڈ ہونا، بیچ بھیجا جانا، کلائنٹ کا جواب، ادائیگی جمع/تصدیق ہونا — خودکار طور پر ریکارڈ ہوتا ہے۔',
    ]),
    GuideSection(title: 'آپ کی سطح اور کارکردگی', paragraphs: [
      'اپنی تصویر پر دبائیں (یا **میری کارکردگی** کھولیں) تاکہ کوالٹی سکور اور اگلی سطح کی طرف اصل پیش رفت دیکھ سکیں — کتنی مزید تصدیق شدہ پروفائلز، کتنا سکور، کتنے دن چاہئیں۔',
      'تینوں شرائط پوری ہوتے ہی سطح خودکار بڑھ جاتی ہے۔ **اونچی سطحیں ہر فروخت پر زیادہ کمیشن کماتی ہیں** — درست موجودہ شرحوں کے لیے کارکردگی صفحے پر "سطح کے مطابق کمیشن" جدول دیکھیں۔',
    ]),
    GuideSection(title: 'آپ کی رسائی سے باہر کیا ہے', paragraphs: [
      'پروفائلز کی منظوری، ادائیگی کی **تصدیق** (آپ صرف ثبوت جمع کروا سکتے ہیں)، CNIC یا اصل موبائل نمبر دیکھنا، اور حفاظتی رپورٹس — یہ سب مکمل ایڈمن کردار کے لیے ہیں۔',
    ]),
    GuideSection(title: 'فوری چیک لسٹ', paragraphs: [
      '• نئی لیڈ → **کلائنٹ شامل کریں**، فالو اپ تاریخ مقرر کریں۔',
      '• سمجھیں وہ کیا چاہتے ہیں → **ضروریات** پُر کریں۔',
      '• امیدوار تلاش کریں → **شارٹ لسٹ** ٹیب، **+ شارٹ لسٹ میں شامل کریں** (ضروریات سے خودکار فلٹر)۔',
      '• کلائنٹ کو پسند آئے → اس پر **حتمی قرار دیں** — رضامندی، تجاویز میں منتقلی، 7 دن فالو اپ، سب ایک ساتھ۔',
      '• پہلے پروفائل شیئر کرنی ہو؟ شارٹ لسٹ آئٹم پر **واٹس ایپ پر شیئر کریں** استعمال کریں۔',
      '• کلائنٹ نے دلچسپی دکھائی → تجاویز کے اوپر **💍 حتمی رشتہ** کارڈ دیکھیں۔',
      '• تعارف کروانا ہو؟ براؤز سے امیدوار کی پروفائل پر **رابطے کی درخواست** دیں۔',
      '• یقین نہیں کہ ایپ میسج پہنچے گا؟ خلاصہ ٹیب پر **ایپ سرگرمی کا نشان** دیکھیں۔',
    ]),
  ];
}
