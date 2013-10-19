Unit XT.ColorMath;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT.Types, System.Math, System.SysUtils;

const
  XYZ_Pow: array[0..255] of Extended =
  (
    0.000833805108617455, 0.000983676774575282, 0.00114818787272903, 0.0013277207825715, 0.00152264380536789, 0.00173331246767887, 0.00196007063932566, 0.00220325150049889, 0.00246317838482483, 0.00274016551939542, 0.00303451867842496, 0.00334653576389916, 0.00367650732404743, 0.0040247170184963, 0.00439144203741029, 0.00477695348069373, 0.00518151670233839, 0.00560539162420272, 0.00604883302285705, 0.00651209079259447, 0.00699541018726539, 0.00749903204322617, 0.00802319298538499, 0.0085681256180693, 0.00913405870222079, 0.00972121732023784, 0.0103298230296269, 0.0109600940064882, 0.0116122451797439, 0.0122864883569159, 0.012983032342173, 0.0137020830472897, 0.0144438435960925, 0.0152085144229127, 0.0159962933655096, 0.0168073757528874, 0.0176419544883841, 0.0185002201283797, 0.0193823609569357, 0.0202885630566524, 0.0212190103760036, 0.0221738847933874, 0.0231533661781104, 0.0241576324485047, 0.0251868596273616, 0.0262412218948499, 0.0273208916390749,
    0.0284260395044208, 0.0295568344378088, 0.0307134437329936, 0.0318960330730115, 0.033104766570885, 0.0343398068086822, 0.0356013148750203, 0.0368894504011, 0.0382043715953465, 0.0395462352767328, 0.0409151969068532, 0.0423114106208097, 0.0437350292569734, 0.0451862043856755, 0.0466650863368801, 0.0481718242268894, 0.0497065659841272, 0.0512694583740432, 0.0528606470231803, 0.0544802764424424, 0.0561284900496001, 0.0578054301910672, 0.0595112381629812, 0.0612460542316176, 0.0630100176531677, 0.0648032666929058, 0.0666259386437729, 0.0684781698444002, 0.0703600956965959, 0.0722718506823175, 0.0742135683801496, 0.0761853814813078, 0.0781874218051863, 0.0802198203144683, 0.0822827071298148, 0.0843762115441488, 0.0865004620365497, 0.0886555862857729, 0.0908417111834077, 0.0930589628466874, 0.0953074666309647,
    0.0975873471418624, 0.0998987282471139, 0.102241733088101, 0.104616484091104, 0.107023102978268, 0.109461710778299, 0.111932427836906, 0.114435373826974, 0.116970667758511, 0.119538427988346, 0.122138772229602, 0.12477181756095, 0.127437680435647, 0.130136476690364, 0.132868321553818, 0.135633329655206, 0.138431615032452, 0.141263291140272, 0.144128470858058, 0.147027266497595, 0.149959789810609, 0.15292615199615, 0.155926463707827, 0.15896083506088, 0.162029375639111, 0.165132194501668, 0.168269400189691, 0.171441100732823, 0.174647403655585, 0.177888415983629, 0.18116424424986, 0.184474994500441, 0.187820772300678, 0.191201682740791, 0.194617830441576, 0.198069319559949, 0.201556253794397, 0.205078736390317, 0.208636870145256, 0.212230757414055, 0.215860500113899, 0.219526199729269, 0.223227957316808, 0.226965873510098, 0.230740048524349, 0.234550582161005, 0.238397573812271, 0.242281122465555, 0.246201326707835, 0.250158284729953, 0.254152094330827,
    0.258182852921596, 0.262250657529696, 0.266355604802862, 0.270497791013066, 0.274677312060385, 0.27889426347681, 0.283148740429992, 0.287440837726917, 0.291770649817536, 0.296138270798321, 0.300543794415776, 0.304987314069886, 0.309468922817508, 0.313988713375718, 0.318546778125092, 0.323143209112951, 0.327778098056542, 0.332451536346179, 0.33716361504833, 0.341914424908661, 0.346704056355029, 0.351532599500439, 0.356400144145943, 0.361306779783509, 0.366252595598839, 0.371237680474149, 0.376262122990906, 0.38132601143253, 0.386429433787049, 0.391572477749723, 0.396755230725627, 0.401977779832196, 0.407240211901737, 0.412542613483904, 0.417885070848137, 0.423267669986072, 0.428690496613907, 0.434153636174749, 0.439657173840919, 0.445201194516228, 0.450785782838223, 0.456411023180405, 0.462076999654407,
    0.467783796112159, 0.473531496148009, 0.479320183100827, 0.48514994005607, 0.491020849847835, 0.49693299506087, 0.502886458032568, 0.508881320854934, 0.514917665376521, 0.520995573204354, 0.527115125705813, 0.533276404010505, 0.539479489012107, 0.545724461370187, 0.552011401512, 0.558340389634268, 0.564711505704929, 0.571124829464873, 0.57758044042965, 0.584078417891164, 0.590618840919337, 0.597201788363763, 0.603827338855337, 0.610495570807865, 0.617206562419651, 0.623960391675076, 0.630757136346147, 0.637596873994032, 0.644479681970582, 0.651405637419824, 0.658374817279448, 0.665387298282272, 0.672443156957687, 0.679542469633094, 0.686685312435313, 0.69387176129199, 0.701101891932973, 0.708375779891687, 0.715693500506481, 0.723055128921969, 0.730460740090353, 0.737910408772731, 0.745404209540387, 0.752942216776078, 0.760524504675292, 0.768151147247507, 0.775822218317423, 0.783537791526193, 0.79129794033263, 0.799102738014409, 0.806952257669251, 0.814846572216101,
    0.822785754396283, 0.830769876774655, 0.83879901174074, 0.846873231509858, 0.854992608124234, 0.863157213454102, 0.871367119198797, 0.879622396887832, 0.887923117881966, 0.896269353374267, 0.904661174391149, 0.913098651793419, 0.921581856277294, 0.930110858375423, 0.938685728457888, 0.9473065367332, 0.955973353249286, 0.964686247894465, 0.973445290398412, 0.982250550333117, 0.99110209711383, 1
  );
  XYZ_Div13: array[0..255] of Extended =
  (
    0, 0.000303526983548837, 0.000607053967097675, 0.000910580950646512, 0.00121410793419535, 0.00151763491774419, 0.00182116190129302, 0.00212468888484186, 0.0024282158683907, 0.00273174285193954, 0.00303526983548837, 0.00333879681903721, 0.00364232380258605, 0.00394585078613489, 0.00424937776968372, 0.00455290475323256, 0.0048564317367814, 0.00515995872033024, 0.00546348570387907, 0.00576701268742791, 0.00607053967097675, 0.00637406665452559, 0.00667759363807442, 0.00698112062162326, 0.0072846476051721, 0.00758817458872094, 0.00789170157226977, 0.00819522855581861, 0.00849875553936745, 0.00880228252291629, 0.00910580950646512, 0.00940933649001396, 0.0097128634735628, 0.0100163904571116, 0.0103199174406605, 0.0106234444242093, 0.0109269714077581, 0.011230498391307, 0.0115340253748558, 0.0118375523584047, 0.0121410793419535, 0.0124446063255023, 0.0127481333090512, 0.0130516602926, 0.0133551872761488, 0.0136587142596977, 0.0139622412432465, 0.0142657682267954,
    0.0145692952103442, 0.014872822193893, 0.0151763491774419, 0.0154798761609907, 0.0157834031445395, 0.0160869301280884, 0.0163904571116372, 0.0166939840951861, 0.0169975110787349, 0.0173010380622837, 0.0176045650458326, 0.0179080920293814, 0.0182116190129302, 0.0185151459964791, 0.0188186729800279, 0.0191221999635768, 0.0194257269471256, 0.0197292539306744, 0.0200327809142233, 0.0203363078977721, 0.0206398348813209, 0.0209433618648698, 0.0212468888484186, 0.0215504158319675, 0.0218539428155163, 0.0221574697990651, 0.022460996782614, 0.0227645237661628, 0.0230680507497116, 0.0233715777332605, 0.0236751047168093, 0.0239786317003582, 0.024282158683907, 0.0245856856674558, 0.0248892126510047, 0.0251927396345535, 0.0254962666181023, 0.0257997936016512, 0.0261033205852, 0.0264068475687489,
    0.0267103745522977, 0.0270139015358465, 0.0273174285193954, 0.0276209555029442, 0.027924482486493, 0.0282280094700419, 0.0285315364535907, 0.0288350634371396, 0.0291385904206884, 0.0294421174042372, 0.0297456443877861, 0.0300491713713349, 0.0303526983548837, 0.0306562253384326, 0.0309597523219814, 0.0312632793055303, 0.0315668062890791, 0.0318703332726279, 0.0321738602561768, 0.0324773872397256, 0.0327809142232744, 0.0330844412068233, 0.0333879681903721, 0.033691495173921, 0.0339950221574698, 0.0342985491410186, 0.0346020761245675, 0.0349056031081163, 0.0352091300916651, 0.035512657075214, 0.0358161840587628, 0.0361197110423117, 0.0364232380258605, 0.0367267650094093, 0.0370302919929582, 0.037333818976507, 0.0376373459600558, 0.0379408729436047, 0.0382443999271535, 0.0385479269107024, 0.0388514538942512, 0.0391549808778, 0.0394585078613489, 0.0397620348448977, 0.0400655618284465, 0.0403690888119954, 0.0406726157955442, 0.0409761427790931, 0.0412796697626419,
    0.0415831967461907, 0.0418867237297396, 0.0421902507132884, 0.0424937776968372, 0.0427973046803861, 0.0431008316639349, 0.0434043586474838, 0.0437078856310326, 0.0440114126145814, 0.0443149395981303, 0.0446184665816791, 0.0449219935652279, 0.0452255205487768, 0.0455290475323256, 0.0458325745158745, 0.0461361014994233, 0.0464396284829721, 0.046743155466521, 0.0470466824500698, 0.0473502094336186, 0.0476537364171675, 0.0479572634007163, 0.0482607903842652, 0.048564317367814, 0.0488678443513628, 0.0491713713349117, 0.0494748983184605, 0.0497784253020093, 0.0500819522855582, 0.050385479269107, 0.0506890062526559, 0.0509925332362047, 0.0512960602197535, 0.0515995872033024, 0.0519031141868512, 0.0522066411704, 0.0525101681539489, 0.0528136951374977, 0.0531172221210466, 0.0534207491045954,
    0.0537242760881442, 0.0540278030716931, 0.0543313300552419, 0.0546348570387907, 0.0549383840223396, 0.0552419110058884, 0.0555454379894373, 0.0558489649729861, 0.0561524919565349, 0.0564560189400838, 0.0567595459236326, 0.0570630729071814, 0.0573665998907303, 0.0576701268742791, 0.057973653857828, 0.0582771808413768, 0.0585807078249256, 0.0588842348084745, 0.0591877617920233, 0.0594912887755721, 0.059794815759121, 0.0600983427426698, 0.0604018697262187, 0.0607053967097675, 0.0610089236933163, 0.0613124506768652, 0.061615977660414, 0.0619195046439628, 0.0622230316275117, 0.0625265586110605, 0.0628300855946094, 0.0631336125781582, 0.063437139561707, 0.0637406665452559, 0.0640441935288047, 0.0643477205123535, 0.0646512474959024, 0.0649547744794512, 0.0652583014630001, 0.0655618284465489, 0.0658653554300977, 0.0661688824136466, 0.0664724093971954, 0.0667759363807442, 0.0670794633642931, 0.0673829903478419, 0.0676865173313908, 0.0679900443149396, 0.0682935712984884,
    0.0685970982820373, 0.0689006252655861, 0.0692041522491349, 0.0695076792326838, 0.0698112062162326, 0.0701147331997815, 0.0704182601833303, 0.0707217871668791, 0.071025314150428, 0.0713288411339768, 0.0716323681175256, 0.0719358951010745, 0.0722394220846233, 0.0725429490681722, 0.072846476051721, 0.0731500030352698, 0.0734535300188187, 0.0737570570023675, 0.0740605839859163, 0.0743641109694652, 0.074667637953014, 0.0749711649365629, 0.0752746919201117, 0.0755782189036605, 0.0758817458872094, 0.0761852728707582, 0.076488799854307, 0.0767923268378559, 0.0770958538214047, 0.0773993808049536
  );

  
function __ICbrt(x:Single): Single; Inline;
procedure ColorToLAB(color:Integer; var L,A,B:Single); Inline;
procedure ColorToLCH(Color:Integer; var L,C,H:Single); Inline;


//--------------------------------------------------
implementation

//Calculates an approximation of cuberoot of a 32-bit number bellow 1.2x til 0.0001 with ok accuracy.
function __ICbrt(x:Single): Single; Inline;
var
  v:LongInt;
begin
  v:=LongInt((@x)^);
  v:=v-$3F800000;
  v:=v shr 1;
  v:=v+$3F800000;
  x:=Single((@v)^);
  if x<0 then x:=-x;
  v:=LongInt((@x)^);
  v:=v-$3F800000;
  v:=v shr 1;
  v:=v+$3F800000;
  Result:=Single((@v)^);
  if Result<0 then Result:=-Result;
  Result := x + ((Result - x)/2);
end;


procedure ColorToLAB(color:Integer; var L,A,B:Single); Inline;
var
  IR,IG,IB:Byte;
  vR,vG,vB,X,Y,Z: Single;
begin
  IR := (color and $FF);
  IG := ((color shr 8) and $FF);
  IB := ((color shr 16) and $FF);

  if IR > 10 then begin vR := XYZ_Pow[IR]; end
  else vR := XYZ_Div13[IR];
  if IG > 10 then begin vG := XYZ_Pow[IG]; end
  else vG := XYZ_Div13[IG];
  if IB > 10 then begin vB := XYZ_Pow[IB]; end
  else vB := XYZ_Div13[IB];

  //Approx 0 deg, Illuminant = D65
  X := vR * 0.4220 + vG * 0.3850 + vB * 0.1930;
  Y := vR * 0.2126 + vG * 0.7152 + vB * 0.0722;
  Z := vR * 0.0170 + vG * 0.1030 + vB * 0.8800;

  if X > 0.008856 then begin X := __ICbrt(X); end
  else X := (7.787 * X) + 0.1379310345;
  if Y > 0.008856 then begin Y := __ICbrt(Y); end
  else Y := (7.787 * Y) + 0.1379310345;
  if Z > 0.008856 then begin Z := __ICbrt(Z); end
  else Z := (7.787 * Z) + 0.1379310345;

  L := (116.0 * Y) - 16.0;
  A := 500.0 * (X - Y);
  B := 200.0 * (Y - Z);
end;


procedure ColorToLCH(Color:Integer; var L,C,H:Single); Inline;
var
  A,B: Single;
begin
  ColorToLAB(Color, L,A,B);
  C := Sqrt(A*A + B*B);
  H := ArcTan2(B,A);
  if (H > 0) then H := (H / 3.1415926536) * 180
  else H := 360 - (-H / 3.1415926536) * 180;
end;

end.
