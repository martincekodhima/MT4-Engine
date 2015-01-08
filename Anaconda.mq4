//+------------------------------------------------------------------+
//|                                                     Anaconda.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Daniil Kolodkin and Martin Cekodhima"
#property link      "http://www.example.com"
#property version   "1.00"
#property strict
input int    Difference = 5000;
input int    PipsTakeProfit = 30000;

//Works best on gold

//Declare variables
double TakeProfitBuy;
double TakeProfitSell;
double BuyLine;
double SellLine;
int    OpenOrders;
double LotNumber;
int    BarsCount;
int    orders;
double Spread;
double StopLossBuy;
double StopLossSell;

int    PreviousOrders;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   switch(OpenOrders){
   
      case(0):  LotNumber = 0.01; break;
      case(1):  LotNumber = 0.02; break;
      case(2):  LotNumber = 0.03; break;
      case(3):  LotNumber = 0.05; break;
      case(4):  LotNumber = 0.08; break;
      case(5):  LotNumber = 0.12; break;
      case(6):  LotNumber = 0.18; break;
      case(7):  LotNumber = 0.27; break;
      case(8):  LotNumber = 0.4; break;
      case(9):  LotNumber = 0.6; break;  
      case(10): LotNumber = 0.9; break;
      case(11): LotNumber = 1.35; break;
      case(12): LotNumber = 2.02; break;
      case(13): LotNumber = 3.03; break;
      case(14): LotNumber = 4.54; break;
      case(15): LotNumber = 6.81; break;
      case(16): LotNumber = 10.22; break;
      case(17): LotNumber = 15.32; break;
      case(18): LotNumber = 22.98; break;
      case(19): LotNumber = 34.47; break;
      case(20): LotNumber = 51.7; break;
      default:  LotNumber = 0.01; break;  
   }

   
   if(OpenOrders == 0){
      //If no orders are present restart all variables
      //Need to calculate the buy line and the sell line
      BuyLine = Ask;
      SellLine = Bid-(Difference*Point);
      
      //Open the new take profit lines for both buy and sell
      TakeProfitSell = NormalizeDouble(SellLine-PipsTakeProfit*Point, Digits);
      TakeProfitBuy  = NormalizeDouble(BuyLine+PipsTakeProfit*Point, Digits);
      
      StopLossBuy = NormalizeDouble(SellLine-PipsTakeProfit*Point, Digits);
      StopLossSell  = NormalizeDouble(BuyLine+PipsTakeProfit*Point, Digits);
      
      Spread = NormalizeDouble(Ask-Bid, Digits);
      
      if(OrderSend(Symbol(), OP_BUY, LotNumber, Ask, 3, StopLossBuy, TakeProfitBuy-Spread, "Order 1 is open at asking price of " + DoubleToStr(Ask, Digits), 0, 0, clrGreen) < 0){
         Alert("Order failed with error #"+DoubleToStr(GetLastError()));
      }
      OpenOrders++;
      
   }else{
      if(OpenOrders > (OrdersTotal()-PreviousOrders)){
         //Orders should have closed and its time to reset all the variables
         OpenOrders = 0;
         PreviousOrders = OrdersTotal();
      }else{

         if(PreviousOrderSell(OpenOrders)){
            //Previous order is buy
            if (EntryConditionBuy()){
               
               if (Bars > BarsCount){
               
                  if (OrderSend(Symbol(), OP_BUY, LotNumber, Ask, 3, StopLossBuy, TakeProfitBuy-Spread, "Order "+DoubleToStr(orders,Digits)+" is open at asking price of " + DoubleToStr(Ask, Digits), 0, 0, clrGreen) < 0){
                     Alert("Order failed with error #"+DoubleToStr(GetLastError()));
                  }
                  OpenOrders++;
                  BarsCount = Bars;
                  
               }
               
            }
         
         }
         
         if(PreviousOrderBuy(OpenOrders)){
            //Previous order is buy
            if (EntryConditionSell()){
               
               if (Bars > BarsCount){
               
                  if (OrderSend(Symbol(), OP_SELL, LotNumber, Bid, 3, StopLossSell, TakeProfitSell+Spread, "Order "+DoubleToStr(orders,Digits)+" is open at bidding price of " + DoubleToStr(Bid, Digits), 0, 0, clrRed) < 0){
                     Alert("Order failed with error #"+DoubleToStr(GetLastError()));
                  }
                  OpenOrders++;
                  BarsCount = Bars;
               }
               
            }
         
         }
      
      }
      
   }
   
   


   
  }
//+------------------------------------------------------------------+

bool PreviousOrderBuy(int order){
   
   if (order % 2 != 0){
      return true;
   }else{
      return false;
   }
}

bool PreviousOrderSell(int order){

   if (order % 2 == 0){
      return true;
   }else{
      return false;
   }
}

bool EntryConditionBuy(){

   if((Open[1] < Close[1] && Open[1] < BuyLine && Close[1] > BuyLine) || (Close[2] < BuyLine && Open[1] > BuyLine && Close[2] < Open[1])){
      return true;
   }else{
      return false;
   }


}

bool EntryConditionSell(){

   if((Open[1] > Close[1] && Open[1] > SellLine && Close[1] < SellLine) || (Close[2] > SellLine && Open[1] < SellLine && Close[2] > Open[1])){
      return true;
   }else{
      return false;
   }


}