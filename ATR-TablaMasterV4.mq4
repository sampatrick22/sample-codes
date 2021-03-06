#property copyright "나는 나비"
#property link "http://www.friendster.com"

extern string Version = "v 4.6";
extern bool AllPositions = true;
extern bool UseSound = false;
extern string NameFileSound = "expert.wav";

static string emailMsg;

void start() {

  if (AccountNumber() != 10638064) {
    return; /*anti piracy AccountNumber()!=692440 OANDA {*/
  }
  if (IsNewBar()) {
    emailMsg = "";
    for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
          TrailingPositions( OrderSymbol() );
      }
      Sleep(1000);
    }

    if (emailMsg != "") {
      SendNotification(emailMsg);
      SendMail(AccountCompany(), emailMsg);
    }

  }
}

bool IsNewBar() {

  static datetime lastbar;
  datetime curbar = (datetime) SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
  if (lastbar != curbar) {
    lastbar = curbar;
    return true;
  }
  return false;

}

void TrailingPositions(string orderToink = "") {

  const int limitCandleCount = 3;
  
  double atrTR_30P = NormalizeDouble( iATR(OrderSymbol(), PERIOD_D1, 14, 0) * 0.4 , MODE_DIGITS) ;
  
  int highestCandle = iHighest(OrderSymbol(), PERIOD_H4, MODE_HIGH,  limitCandleCount, 0);
  double highestCandleValue = iHigh(OrderSymbol(), PERIOD_H4, highestCandle);
  double sellTrailStoploss = highestCandleValue + atrTR_30P;
  
  int lowestCandle = iLowest(OrderSymbol(), PERIOD_H4, MODE_LOW,  limitCandleCount, 0);
  double lowestCandleValue = iLow(OrderSymbol(), PERIOD_H4, lowestCandle);
  double buyTrailStoploss = lowestCandleValue - atrTR_30P;
  
  double trailGain=0;
  
  

  double diff, gain, pBid, pAsk;
  bool snob = false, toTabla = false;
  string msg = "";

  bool slModified = false;
  
  double spread = MarketInfo(OrderSymbol(), MODE_SPREAD) * 1.5;
  double tabladoValue=OrderOpenPrice();
  
  if (OrderType() == OP_BUY) {
    pBid = MarketInfo(OrderSymbol(), MODE_BID);

    diff = NormalizeDouble(OrderOpenPrice() - OrderStopLoss(), MODE_DIGITS);
    gain = NormalizeDouble(pBid - OrderOpenPrice(), MODE_DIGITS);
    snob = OrderOpenPrice() > OrderStopLoss();
    toTabla = ( gain > NormalizeDouble(diff * 0.8, MODE_DIGITS) || gain > atrTR_30P ) ? true : false;
    tabladoValue = OrderOpenPrice() + NormalizeDouble( spread * MarketInfo(OrderSymbol() , MODE_POINT ), MODE_DIGITS );
     
    if (toTabla && snob) {
      ModifyStopLoss( tabladoValue );
      emailMsg += (OrderSymbol() + " modified to free trade..\n");
      Sleep(1000);
    }


   if ( (OrderStopLoss() < buyTrailStoploss || OrderStopLoss() == 0) && !snob ) {
     gain = (buyTrailStoploss - OrderStopLoss()) / MarketInfo(OrderSymbol(), MODE_POINT);
   
     slModified = ModifyStopLoss( buyTrailStoploss );

     if (slModified) {
       emailMsg += (OrderSymbol() + " +gain: " + gain );
     }
     return;
   }
   
  }
  
  if (OrderType() == OP_SELL) {
    pAsk = MarketInfo(OrderSymbol(), MODE_BID);


    diff = NormalizeDouble(OrderStopLoss() - OrderOpenPrice(), MODE_DIGITS);
    gain = NormalizeDouble(OrderOpenPrice() - pAsk, MODE_DIGITS);
    snob = OrderOpenPrice() < OrderStopLoss();
    toTabla = ( gain > NormalizeDouble(diff * 0.8, MODE_DIGITS) || gain > atrTR_30P )  ? true : false;
    
    tabladoValue = OrderOpenPrice() - NormalizeDouble( spread * MarketInfo(OrderSymbol() , MODE_POINT ), MODE_DIGITS );
    
    if (toTabla && snob) {
      ModifyStopLoss( tabladoValue );
      emailMsg += (OrderSymbol() + " modified to free trade..\n");
      Sleep(1000);
    }


   if ( (OrderStopLoss() > sellTrailStoploss || OrderStopLoss() == 0) && !snob ) {
     slModified = ModifyStopLoss(sellTrailStoploss);
     gain = (sellTrailStoploss - OrderStopLoss()) / MarketInfo(OrderSymbol(), MODE_POINT);
     
     if (slModified) {
       emailMsg += (OrderSymbol() + " +gain: " + gain );
     }
     return;
   }
   
  }


}


bool ModifyStopLoss(double ldStopLoss) {
  bool fm = false;
  
  ldStopLoss = NormalizeDouble(ldStopLoss , MODE_DIGITS);
  
  if (ldStopLoss == OrderStopLoss()) return fm;

  fm = OrderModify(OrderTicket(), OrderOpenPrice(), ldStopLoss, OrderTakeProfit(), 0, CLR_NONE);

  //if (fm && UseSound) PlaySound(NameFileSound);

  return fm;
}