// Mobile adaptation of resources/views/guide/partials/matchmaker.blade.php —
// same structure and facts, condensed for a phone screen and stripped of
// HTML markup. **word** renders bold; a paragraph starting with "• " renders
// as a bullet. Keep this in sync with the web guide when either changes.
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
      'Your own workspace (the **Nikah Counselor Desk**) is separate from the general admin panel — Users, Settings, and Integrations stay off-limits, and everything you do is scoped to the clients assigned to you.',
    ]),
    GuideSection(title: 'Privacy & Security — Read This First', paragraphs: [
      'These aren\'t formalities — they\'re what makes clients trust the system enough to use it.',
      '• **CNIC, photos, and direct contact details are never shown to you.** You work from age, city, education, profession, and other profile fields — never CNIC images or a phone/email. Use **Request Contact** and let admin approve and facilitate an introduction.',
      '• **You don\'t see a client\'s phone number either — not even your own client\'s.** It shows masked everywhere on your screens. You still get a **Copy Link** button for their one secure link, ready to paste into WhatsApp or wherever you\'re already talking to them.',
      '• **You never see the client\'s link either — only a Copy Link button.** Nothing about the link is ever shown as text on your screen.',
      '• **Every visit to a client\'s link is logged** — time, approximate location, device. Not to spy on them, but so there\'s a real record if something ever needs to be checked.',
      '• **Never contact a family directly outside the system.** Even once you know a name or general area, don\'t reach out yourself — that\'s what Request Contact and admin approval exist for.',
      '• **Requirements notes are working notes, not private chat.** Keep the language plain and respectful — describe what someone is looking for, not judgments about people.',
      '• **Some profiles won\'t show up when you search — that\'s intentional.** "Confidential" profiles are hidden from search/browse entirely, even from you. You can only work with one if it\'s already linked to a client you\'re handling.',
    ]),
    GuideSection(title: 'Your Dashboard, Explained', paragraphs: [
      'Logging in takes you straight to the Nikah Counselor Desk — not the general member dashboard.',
      '• **New Leads / Follow-ups Due / Registered** — where your assigned clients currently stand.',
      '• **Active Batches** — proposal batches you\'ve sent that are still waiting on a full response.',
      '• **Awaiting Response** — individual candidates you\'ve sent that the client hasn\'t replied to yet.',
      '• **Interested This Week** — a quick pulse on recent positive responses.',
      'Your avatar in the top bar carries a small badge showing your current level (🥉 Nikah Counselor → 🥈 Certified → 🥇 Senior → ⭐ Regional Coordinator) — tap it any time to open **My Performance**.',
    ]),
    GuideSection(title: 'Step 1 — Add a Client', paragraphs: [
      'Most real leads arrive over WhatsApp or a Facebook/Instagram ad and never register themselves. Press **Add Client** and record their name, phone/email, gender, and source — they\'re assigned to you automatically.',
      'The moment you save a phone number, their one secure link is generated automatically — no separate step. Update their **Status** as things move (New → Contacted → Interested → Registered, or Not Interested/Closed), and set a **Next Follow-up** date so it surfaces on your dashboard.',
    ]),
    GuideSection(title: 'Step 2 — Capture Requirements', paragraphs: [
      'On a client\'s page, open the **Requirements** tab and record what they\'re actually looking for — age range, city, education, marital status, and so on — each marked **Must Have**, **Preferred**, or **Flexible**. This isn\'t shown to the client; it guides your own candidate search.',
    ]),
    GuideSection(title: 'Step 3 — Build a Shortlist', paragraphs: [
      'In the **Shortlist** tab, search verified profiles (filter by gender/city/sect) and add promising candidates with a short note on why each one fits. Nothing is sent to the client yet.',
      'If you\'ve already saved Requirements, check **Suggested Matches** at the top first — it ranks the active profile pool against what you saved and tags each one 🟢 High, 🟡 Medium, or ⚪ Low match.',
    ]),
    GuideSection(title: 'Step 4 — Record Consent', paragraphs: [
      'Before you can send this client any proposals, get their **Nikah Counseling Participation** consent on file — found on the Overview tab. The system blocks proposal batches until an active consent exists.',
      'Preferred: press **Ask Them to Confirm via Link** — asks the client directly through their own secure link, only counting once they press "I Agree" themselves. Otherwise, use the second form to record consent you already got verbally, by phone, or in person. To withdraw, press **Revoke** — the original record stays, nothing is deleted.',
    ]),
    GuideSection(title: 'Step 5 — Choosing a Package', paragraphs: [
      'A client picks and pays for their own Nikah counseling package directly on their secure link — you don\'t assign it manually. They see the payment details (JazzCash/EasyPaisa/bank transfer, one-tap copy), upload a screenshot, and it lands in admin\'s review queue. You\'ll see the package appear once admin confirms it.',
    ]),
    GuideSection(title: 'Step 6 — Create & Send a Proposal Batch', paragraphs: [
      'In the **Proposal Batches** tab, start a new batch (needs a linked profile, active consent, and active package first) and add up to **5 candidates** from your shortlist, each with an optional note. Press **Mark as Sent**.',
      'Those candidates appear on the client\'s one secure link, where they respond Interested / Maybe / Not Interested directly — reflected right back in this tab. If the package has a proposal limit, this tab shows how many are left.',
    ]),
    GuideSection(title: 'Sending the Client Their Link', paragraphs: [
      'Every client gets exactly **one** link, generated automatically the moment you save a phone number. On Overview, press **Copy Link** and paste it wherever you\'re already talking to them — the link text is never shown on screen, by design.',
      'That link is where they confirm consent, choose and pay for a package, review proposed matches, upload documents, and check status — every time, nothing separate to send. If anything feels off, press **Regenerate** — the old copy stops working immediately.',
    ]),
    GuideSection(title: 'Step 7 — Registering a New Client', paragraphs: [
      'If someone\'s ready to register, open their client page and press **Register Nikah Profile** — this opens the walk-in wizard with their name and phone/email already filled in.',
    ]),
    GuideSection(title: 'Registering Someone You Can\'t Meet In Person', paragraphs: [
      '**Never collect a lead\'s CNIC over WhatsApp** — not the number, not a photo of it, not their picture. If registering remotely, check "send them a secure link to upload it themselves" on the Verification step — their profile is created without those documents, and their secure link will show a document-upload step next visit.',
      'This only works if they have a phone/WhatsApp number on file.',
    ]),
    GuideSection(title: 'Collecting Their Verification Fee Payment', paragraphs: [
      'If a fee applies and your client pays you directly, get the complete document set — CNIC photos and payment receipt — into the system together. Two ways: during registration (the wizard\'s Payment step), or afterward from the client\'s linked Nikah profile.',
      'Either way, this only submits proof for admin to confirm — it doesn\'t mark the fee as paid on its own.',
    ]),
    GuideSection(title: 'Reading the Activity Timeline', paragraphs: [
      'Every meaningful action — lead received, status change, profile linked, requirements saved, candidate shortlisted, batch sent, client response, payment submitted/confirmed, link regenerated — logs automatically to the **Timeline** tab. Use it to pick up a client\'s history at a glance.',
    ]),
    GuideSection(title: 'Your Level & Performance', paragraphs: [
      'Tap your avatar (or open **My Performance**) to see your Quality Score — built from Verification Rate, Paid Conversion Rate, and Compliance — plus a real progress breakdown toward your next level: exactly how many more verified profiles, how much quality score, and how many more days you need.',
      'Levels are promoted automatically once you clear all three for a level — nothing to request. **Higher levels earn a higher commission rate on every sale** — see the Commission by Level table on your Performance page for the exact current rates.',
    ]),
    GuideSection(title: 'What\'s Outside Your Access', paragraphs: [
      'Approving/rejecting profiles, **confirming** a submitted verification or package payment (you can submit proof, but only admin confirms it), viewing CNIC images or a client\'s real phone number, and reviewing safety reports need the full Admin role. Flag anything that needs that level of action to an admin.',
    ]),
    GuideSection(title: 'Quick Checklist', paragraphs: [
      '• New lead comes in → **Add Client** with a phone number — their link generates itself, set a follow-up date.',
      '• Understand what they want → fill in **Requirements**.',
      '• Find candidates → check **Suggested Matches**, then search & build a **Shortlist**.',
      '• Record their **consent** on Overview — required before sending proposals.',
      '• Client chooses & pays for their own **package** on their link — you wait for admin to confirm.',
      '• Registered profile + active consent + active package → start a **Proposal Batch**, add up to 5 candidates, **Mark as Sent**.',
      '• **Copy Link** once from Overview, send it however reaches them — that one link covers everything, forever.',
      '• Anything feels off (leaked link, suspicious activity)? **Regenerate**, and tell an admin if needed.',
    ]),
  ];

  static const _ur = <GuideSection>[
    GuideSection(title: 'آپ کا کردار', paragraphs: [
      'ایک نکاح مشیر کے طور پر، آپ سلامتی پر خاندانوں کو جوڑنے میں مدد کرتے ہیں — واٹس ایپ/فیس بک/انسٹاگرام سے لیڈز حاصل کرنا، رجسٹریشن میں مدد، یہ سمجھنا کہ وہ اصل میں کیا تلاش کر رہے ہیں، اور موزوں امیدواروں کے لیے تجاویز تیار کرنا۔',
      'آپ کا اپنا ورک اسپیس (**نکاح مشیر ڈیسک**) عمومی ایڈمن پینل سے الگ ہے — یوزرز، سیٹنگز، اور انٹیگریشنز آپ کی رسائی سے باہر رہتے ہیں، اور آپ صرف اپنے تفویض کردہ کلائنٹس تک محدود ہیں۔',
    ]),
    GuideSection(title: 'رازداری اور سیکیورٹی — یہ پہلے پڑھیں', paragraphs: [
      'یہ محض رسمی باتیں نہیں — یہی وہ چیزیں ہیں جو کلائنٹس کو نظام پر اعتماد کے قابل بناتی ہیں۔',
      '• **شناختی کارڈ، تصاویر، اور رابطہ کی تفصیلات آپ کو کبھی نہیں دکھائی جاتیں۔** عمر، شہر، تعلیم، پیشہ جیسی تفصیلات سے کام لیں — کبھی CNIC یا فون/ای میل نہیں۔ تعارف کے لیے **رابطے کی درخواست** استعمال کریں۔',
      '• **کلائنٹ کا موبائل نمبر بھی نہیں دکھایا جاتا — اپنے کلائنٹ کا بھی نہیں۔** ہر جگہ چھپا ہوا نظر آتا ہے۔ آپ کو **لنک کاپی کریں** بٹن ملتا ہے۔',
      '• **کلائنٹ کا لنک بھی نظر نہیں آتا — صرف کاپی لنک بٹن۔** لنک کبھی متن کے طور پر نہیں دکھایا جاتا۔',
      '• **ہر وزٹ ریکارڈ ہوتی ہے** — وقت، تخمینی مقام، آلہ۔ جاسوسی کے لیے نہیں بلکہ حقیقی ریکارڈ کے لیے۔',
      '• **نظام سے باہر کبھی براہ راست رابطہ نہ کریں۔** رابطے کی درخواست اور ایڈمن کی منظوری کا نظام موجود ہے۔',
      '• **ضروریات کے نوٹس کام کے نوٹس ہیں، نجی چیٹ نہیں۔** زبان سادہ اور باوقار رکھیں۔',
      '• **کچھ پروفائلز تلاش میں نظر نہیں آئیں گی — یہ جان بوجھ کر ہے۔** "خفیہ" پروفائلز آپ سے بھی پوشیدہ ہوتی ہیں، سوائے اس کے کہ پہلے سے آپ کے کسی کلائنٹ سے منسلک ہوں۔',
    ]),
    GuideSection(title: 'آپ کا ڈیش بورڈ سمجھیں', paragraphs: [
      'لاگ اِن کرنے پر آپ براہ راست نکاح مشیر ڈیسک پر پہنچتے ہیں۔',
      '• **نئی لیڈز / فالو اپ باقی / رجسٹرڈ** — آپ کے کلائنٹس اس وقت کہاں کھڑے ہیں۔',
      '• **فعال بیچز** — بھیجے گئے بیچز جن کا مکمل جواب باقی ہے۔',
      '• **جواب کا انتظار** — بھیجے گئے امیدوار جن کا جواب نہیں آیا۔',
      '• **اس ہفتے دلچسپی** — حالیہ مثبت جوابات پر ایک نظر۔',
      'اوپر بار میں آپ کی تصویر پر آپ کی موجودہ سطح کا چھوٹا نشان ہوتا ہے (🥉 → 🥈 → 🥇 → ⭐) — کسی بھی وقت **میری کارکردگی** کھولنے کے لیے دبائیں۔',
    ]),
    GuideSection(title: 'مرحلہ 1 — کلائنٹ شامل کریں', paragraphs: [
      'زیادہ تر لیڈز واٹس ایپ یا فیس بک/انسٹاگرام سے آتی ہیں اور خود رجسٹر نہیں ہوتیں۔ **کلائنٹ شامل کریں** دبائیں اور نام، فون/ای میل، جنس، ذریعہ درج کریں — وہ خودکار طور پر آپ کو تفویض ہوں گے۔',
      'فون نمبر محفوظ کرتے ہی ان کا محفوظ لنک خودکار بن جاتا ہے۔ **حیثیت** اپ ڈیٹ کرتے رہیں اور **اگلا فالو اپ** تاریخ مقرر کریں۔',
    ]),
    GuideSection(title: 'مرحلہ 2 — ضروریات درج کریں', paragraphs: [
      '**ضروریات** ٹیب میں وہ کچھ درج کریں جو کلائنٹ اصل میں تلاش کر رہا ہے — ہر ایک کو **لازمی**، **ترجیحی**، یا **لچکدار** نشان زد کریں۔ یہ کلائنٹ کو نہیں دکھایا جاتا۔',
    ]),
    GuideSection(title: 'مرحلہ 3 — شارٹ لسٹ بنائیں', paragraphs: [
      '**شارٹ لسٹ** ٹیب میں تصدیق شدہ پروفائلز تلاش کر کے امید افزا امیدوار ایک نوٹ کے ساتھ شامل کریں۔ ابھی کچھ کلائنٹ کو نہیں بھیجا جاتا۔',
      'اگر ضروریات پہلے سے محفوظ ہیں تو پہلے **تجویز کردہ میچز** دیکھیں — 🟢 اعلیٰ، 🟡 درمیانہ، یا ⚪ کم میچ کا نشان۔',
    ]),
    GuideSection(title: 'مرحلہ 4 — رضامندی لینا', paragraphs: [
      'تجویز بھیجنے سے پہلے **نکاح مشاورت میں شرکت** کی رضامندی خلاصہ ٹیب پر درج ہونی چاہیے — بغیر اس کے نظام تجویز بھیجنے نہیں دے گا۔',
      'ترجیحی: **انہیں لنک پر تصدیق کرنے کو کہیں** — رضامندی تبھی شمار ہوگی جب وہ خود "میں راضی ہوں" دبائیں۔ یا نیچے دیے گئے فارم سے پہلے سے حاصل شدہ رضامندی درج کریں۔ واپس لینے کے لیے **منسوخ کریں** دبائیں۔',
    ]),
    GuideSection(title: 'مرحلہ 5 — پیکج کا انتخاب', paragraphs: [
      'کلائنٹ اپنا پیکج خود اپنے لنک پر منتخب اور ادا کرتا ہے۔ وہ رسید اپلوڈ کرتے ہیں، جو ایڈمن کے جائزے میں جاتی ہے۔ تصدیق کے بعد پیکج آپ کو نظر آئے گا۔',
    ]),
    GuideSection(title: 'مرحلہ 6 — تجویز بیچ بنائیں اور بھیجیں', paragraphs: [
      '**تجویز بیچز** ٹیب میں نیا بیچ شروع کریں اور شارٹ لسٹ سے **5 امیدواروں تک** شامل کریں۔ **بھیجا گیا نشان زد کریں** دبائیں۔',
      'امیدوار سیدھا کلائنٹ کے لنک پر نظر آتے ہیں جہاں وہ جواب دیتے ہیں — اسی ٹیب میں فوراً نظر آ جائے گا۔',
    ]),
    GuideSection(title: 'کلائنٹ کو لنک بھیجنا', paragraphs: [
      'ہر کلائنٹ کو بالکل **ایک** لنک ملتا ہے۔ **لنک کاپی کریں** دبائیں اور جہاں بھی بات ہو رہی ہو وہاں پیسٹ کریں — لنک کبھی سکرین پر نہیں دکھایا جاتا۔',
      'یہی لنک رضامندی، پیکج، تجاویز، دستاویزات، اور حیثیت — سب کے لیے استعمال ہوتا ہے۔ کچھ غلط لگے تو **دوبارہ بنائیں** دبائیں۔',
    ]),
    GuideSection(title: 'مرحلہ 7 — نئے کلائنٹ کی رجسٹریشن', paragraphs: [
      'رجسٹریشن کے لیے تیار ہونے پر کلائنٹ کا صفحہ کھولیں اور **نکاح پروفائل رجسٹر کریں** دبائیں — یہ واک اِن عمل کھولتا ہے، نام اور فون/ای میل پہلے سے بھرا ہوتا ہے۔',
    ]),
    GuideSection(title: 'اگر آپ کسی سے خود مل نہ سکیں', paragraphs: [
      '**کسی کا CNIC کبھی واٹس ایپ پر نہ منگوائیں۔** دور بیٹھے شخص کے لیے ویریفیکیشن مرحلے میں "محفوظ لنک بھیج دیں" باکس ٹک کریں۔',
      'یہ تب ہی کام کرے گا جب فون/واٹس ایپ نمبر درج ہو۔',
    ]),
    GuideSection(title: 'تصدیقی فیس کی ادائیگی وصول کرنا', paragraphs: [
      'اگر فیس لاگو ہو اور کلائنٹ آپ کو براہ راست ادا کرے، تو CNIC اور رسید ایک ساتھ داخل کریں — رجسٹریشن کے دوران یا بعد میں پروفائل سے۔',
      'یہ صرف ایڈمن کی تصدیق کے لیے ثبوت جمع کرواتا ہے۔',
    ]),
    GuideSection(title: 'سرگرمی کی ٹائم لائن', paragraphs: [
      'ہر اہم عمل خودکار طور پر **ٹائم لائن** ٹیب میں ریکارڈ ہوتا ہے — کلائنٹ کی تاریخ ایک نظر میں سمجھنے کے لیے استعمال کریں۔',
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
      '• امیدوار تلاش کریں → **تجویز کردہ میچز** دیکھیں، پھر **شارٹ لسٹ** بنائیں۔',
      '• خلاصہ پر **رضامندی** درج کریں — تجاویز بھیجنے سے پہلے لازمی۔',
      '• کلائنٹ خود **پیکج** منتخب اور ادا کرے گا۔',
      '• رجسٹرڈ پروفائل + رضامندی + پیکج → **تجویز بیچ** شروع کریں، **بھیجا گیا نشان زد کریں**۔',
      '• ایک بار **لنک کاپی کریں** — وہی لنک ہمیشہ کے لیے سب کچھ سنبھالے گا۔',
      '• کچھ غلط ہو تو **دوبارہ بنائیں** اور ایڈمن کو بتائیں۔',
    ]),
  ];
}
