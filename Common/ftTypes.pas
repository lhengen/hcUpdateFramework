unit ftTypes;

interface

uses
  hcTypes
  ,hcConsts
  ;


type
  TftTipPercentage = (tpNone,tp5,tp10,tp15,tp20,tp25,tp30);
  TftComboStudio = class(TObject)
    Name,
    GUID :string;
    Number :Integer;
  end;
  TftComboStateProvince = class(TObject)
    Name,
    GUID :string;
  end;
  TftComboDate = class(TObject)
    DateValue :TDateTime;
    DateString :string;
  end;
  TftLifeStylePassPaymentType = (ptCreditCard,ptDebitCard,ptOnNextVisit);
  TftLifeStylePaymentStatus = (psSkipped,psFree,psReturned,psPaid,psUnPaid);
  TftLifeStylePaymentAction = (paNone,paSkip,paFree,paReturn,paPay,paPayProRate);
  TftAirMilesAction = (amaResubmit = 1,amaSubmit = 2);
  TftLampWarningLevel = (lwlNone,lwlOne,lwlTwo);
  TftEmployeeTransactionType = (ettSales,ettTans);
  TftPackageKind = (pkMinutes, pkVisits, pkDurational);
  TftTanType = (ttSpray,ttUV,ttRedLight,ttAirbrush,ttLash);
  TftBulbType = (btUnKnown, btUV, btRedLight);

  {
    Security Levels
    1 - Bed Cleaner (can login for timesheet tracking but thats it)
    2 - Technician or Part-time CEO (can tan people)
    3 - Manager or Full-time CEO (control over financials etc)
    4 - Franchisee or Administrator (ie: Fabutan Head Office staff)  (God like access)
  }
  TftSecurityLevel = (slBedCleaner = 1,slTechnician = 2,slManager = 3,slAdmin = 4);
  TftLampChangeType = (lcRegular =1,lcFirst=2,lc750Hour=3,lcFull=4);
  TftGoldCardSelectionType = (stForAddon,stForReinstatement,stForRenewal);
  TftDiscountType = (dtPercentage,dtDollarAmount);
  TftGender = (gFemale=1,gMale=2);
  TftMaritalStatus = (msSingle=1,msMarried=2);
  TftPaymentMethod = (pmNone,pmCash,pmDebitCard,pmCheque,pmVisa,pmMasterCard,pmAMEX,pmDiscover);
  TInvoiceStatus = (isOpen, isClosed);
  TInvoiceItemStatus = (iisActive,iisVoid);
  TEmployeeStatus = (esHidden, esActive, esInActive);
  TftPercentRange = 0..100;
  TftRoomFilter = (rfAll,rfAvailable,rfUnderMaintenance,rfInUse,rfAny,rfSprayOnly,rfUVOnly,rfRedLightOnly,rfAirbrushOnly,rfLashOnly);  //filter used for SelectRoom dialog results
  TftRoomFilterSet = set of TftRoomFilter; //filterset since can include or exclude "Any" in combination with Available, UnderMaintenance, and InUse
  TftBedStatus = (bsInactive,bsUnderMaintenance,bsActive);
  TftDynamicKV = array of ThcKeyValuePair;
  TftCardType = (ctGiftCertificate,ctTransfer);
  TftTaxRates = record
    GST,
    PST,
    UDT :double;
    IsHST :boolean;
    IsPSTonGST :boolean;
  end;

  TftReturnInfo = class(TObject)
  public
    Description,
    InvoiceGUID,
    InvoiceProductGUID,
    ClientAccountGUID,
    ProductGUID,
    OptionGUID,
    GiftCertificateGUID,
    CommissionEmployeeGUID,
    GoldCardGUID :string;

    CardNumber :string;

    NegatedOriginalQty :integer;

    DiscountEach,
    BasePriceEach,
    SalePriceEach,
    PriceEach :Currency;

    GSTRate,
    PSTRate,
    UDTRate :single;

    IsSale,
    IsCombo,
    IsSampleCups,
    IsVoided :boolean;

  end;
  TftSecurityInfoType = (itPassword,itPIN);

const
  STR_RedLight = 'Red Light';
  STR_UV = 'UV';

  //in the database [fnPrimaryPackageCategory] Kevin calls these Categories but in Fabware it's TanType
  PackageCategories: array[TftTanType] of string =
  (
    'Spray'
    ,'UV'
    ,'RedLight'
    ,'Airbrush'
    ,'Lash'
  );

  SecurityLevelNames :array[TftSecurityLevel] of string =
  (
   'Bed Cleaner',
   'Technician',
   'Manager',
   'Admin'
  );

  LifeStylePaymentStatusNames :array[TftLifeStylePaymentStatus] of string =
  (
   'Skipped',
   'Free',
   'Returned',
   'Paid',
   'Unpaid'
  );

  LifeStylePaymentActionNames :array[TftLifeStylePaymentAction] of string =
  (
   '',
   'Skip',
   'Free',
   'Return',
   'Pay',
   'PayProRate'
  );


  PackageKindString : array[TftPackageKind] of string = ('Minutes','Visits','Expiry');

  //used by routine to strip out undesired payment methods
  AmexCode :string = 'A';
  DiscoverCode :string = 'S';
  ChequeCode :string = 'Q';

  CardTypeKV :array[TftCardType] of ThcKeyValuePair =
  (
    ('G','Gift Certificate'),
    ('T','Transfer Card')
  );

  PaymentMethodKV :array[TftPaymentMethod] of ThcKeyValuePair =
  (
    ('N','None'),
    ('C','Cash'),
    ('D','Debit Card'),
    ('Q','Cheque'),
    ('V','Visa'),
    ('M','MasterCard'),
    ('A','AMEX'),
    ('S','Discover')
  );

  ReferralSource :array[1..11] of string = ('Radio Advertising','Outdoor Advertising','Flyer/Coupon','Online Advertisement','Online Search','Print Advertisement','Social Media','Friend or Family Referral','Owner/Staff member Referral','Signage','Other');

  GenderKV :array[1..3] of ThcKeyValuePair =
  (
    (hcConsts.NullKVKey,'UnSpecified'),
    ('F','Female'),
    ('M','Male')
  );

  SalutationKV :array[1..3] of ThcKeyValuePair =      //maps a salutation selection into a GenderKV key value
  (
    (hcConsts.NullKVKey,'UnSpecified'),
    ('F','Ms./Mrs.'),
    ('M','Mr.')
  );

  MaritalStatusKV :array[1..3] of ThcKeyValuePair =
  (
    (hcConsts.NullKVKey,'UnSpecified'),
    ('S','Single'),
    ('M','Married')
  );

  BedBulbTypesKV  :array[TftBulbType] of ThcKeyValuePair =
  (
    (hcConsts.NullKVKey,'Not Applicable'),
    (STR_UV,STR_UV),
    (STR_RedLight,STR_RedLight)
  );

  BedStatusKV :array[TftBedStatus] of ThcKeyValuePair =
  (
    ('I','Delete'),   //bed is "removed" and will nto be displayed in list
    ('M','Maintenance'), //bed is under maintenance.  It is displayed but cannot be used
    ('A','Active')      //Bed is usable
  );

  EmployeeStatusCodes :array[TEmployeeStatus] of string = ('H','A','I');
  EmployeeStatusNames :array[TEmployeeStatus] of string = ('Hidden','Active','InActive');


  DiscountTypeNames :array[TftDiscountType] of String = ('Percentage (%)','Dollar Amount ($)');

  LampChangeTypeNames :array[TftLampChangeType] of string =
    (
      'Regular',
      'First',
      '750 Hour',
      'Full'
     );
  LampChangeTypeDescriptions :array[TftLampChangeType] of string =
    (
      'A REGULAR Lamp Change is Swapping the TOP Lamps to the BOTTOM, and Replacing the TOP Lamps.',
      'A FIRST Lamp Change is Replacing the TOP Lamps, and Leaving the BOTTOM Lamps in place.',
      'A 750 Hour Bulb Change Leave TOP Lamps, Swap Stored Lamps to the BOTTOM',
      'A FULL Lamp Change means you are Replacing BOTH TOP and BOTTOM Lamps'
    );


function PaymentKeyToValue(const KeyCode :string) :string;

implementation

function PaymentKeyToValue(const KeyCode :string) :string;
var
  I :TftPaymentMethod;
begin
  for I := low(TftPaymentMethod) to high(TftPaymentMethod) do
  begin
    if (PaymentMethodKV[I,Key] = KeyCode) then
    begin
      Result := PaymentMethodKV[I,Value];
      break;
    end;
  end;
end;


end.
