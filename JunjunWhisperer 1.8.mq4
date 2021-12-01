//+------------------------------------------------------------------+
//|                                              JunjunWhisperer.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                           https://www.kamote.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

enum lotSizeOptions{
   A1	= 0,	//0.25
   A2	= 1,	//0.30
   A3	= 2,	//0.35
   A4	= 3,	//0.40
   A5	= 4,	//0.45
   A6	= 5,	//0.50
   A7	= 6,	//0.55
   A8	= 7,	//0.60
   A9	= 8, 	//0.65
   A10 = 9,  //0.70
   A11 = 10  //0.75

};

input lotSizeOptions LotSize  = A1;
double lotsArray[] = {0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75 };
double finalLotSize = 0.25;
int OnInit(){
//---
   finalLotSize = lotsArray[LotSize];
   
   //Alert(finalLotSize);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool IsNewBar(){

   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   if(lastbar != curbar){
      lastbar = curbar;
      return true;
   }
   return false;
   
}

bool wallExists(){


   int rektCount=0;
   
   for(int i = ObjectsTotal()-1; i>=0; i--){
   
      string objName  = ObjectName(i);
      
      if( ObjectType(objName)!=OBJ_RECTANGLE ) continue;

      double topPrice = ObjectGet(objName,OBJPROP_PRICE1);
      double botPrice = ObjectGet(objName,OBJPROP_PRICE2);
      datetime timeMin = MathMin((long)ObjectGet(objName, OBJPROP_TIME1) , (long)ObjectGet(objName, OBJPROP_TIME2) );
      datetime timeMax = MathMax((long)ObjectGet(objName, OBJPROP_TIME1) , (long)ObjectGet(objName, OBJPROP_TIME2) );


      int wallColor = ObjectGet(objName,OBJPROP_COLOR);
      

      
      if(wallColor == 0){ /* may wall ung pending*/
         rektCount++;
 
         if(topPrice>Bid && Bid>botPrice){
          //Comment (timeMin, "   ", timeMax,  " status of rect ", timeMin < TimeCurrent() && timeMax> TimeCurrent() );
         
            if(timeMin<TimeCurrent() && timeMax>TimeCurrent()){
               ObjectDelete(ChartID(), objName);
               Sleep(100);
            }
         }else{
            Comment("");
         }


      }else{
         continue;
      }
      

   
   }
   //Comment(rektCount!=0);
   return rektCount!=0;
   
}

int plotPending(){
   for(int i = ObjectsTotal()-1; i>=0; i--){
   
      string objT  = ObjectName(i);
      
      if( ObjectType(objT)==OBJ_FIBO ) {
      
         string pricee= ( NormalizeDouble( ObjectGet(objT, OBJPROP_PRICE1), Digits )+"\t"+NormalizeDouble(ObjectGet(objT, OBJPROP_PRICE2), Digits) );
         
         double val1 = NormalizeDouble( ObjectGet(objT, OBJPROP_PRICE1), Digits );
         double val2 = NormalizeDouble( ObjectGet(objT, OBJPROP_PRICE2), Digits );

         double topBound, botBound, diffBound, percenti;
         double pendingSu, tpSu, slSu;
         int order_type;
         
         double Lots    = finalLotSize;
         int slippage   = 3;
         
         
         if(val1>val2){ /*BUY */
                        
            topBound = MathAbs(MathMax(val1, val2));
            botBound = MathAbs(MathMin(val1, val2));
            
            diffBound = MathAbs(topBound)-MathAbs(botBound);
            
            percenti  = MathAbs(diffBound * 0.3);
            
            pendingSu = MathAbs(botBound) + MathAbs(percenti);
            tpSu = topBound;
            slSu = botBound;
            
            
            if(Bid > pendingSu){
               order_type = OP_BUYLIMIT;
            }
            if(Bid < pendingSu){
               order_type = OP_BUYSTOP;
            }
            
         }            
         
         if(val1<val2){ /*SELL FIBO BALIKTAD*/
            topBound = MathAbs(MathMax(val1, val2));
            botBound = MathAbs(MathMin(val1, val2));
            
            diffBound = MathAbs(topBound)-MathAbs(botBound);
            
            percenti  = MathAbs(diffBound * 0.3);
            
            pendingSu = MathAbs(topBound) - MathAbs(percenti);
            tpSu = botBound;
            slSu = topBound;               

            if(Bid < pendingSu){
               order_type = OP_SELLLIMIT;
            }
            if(Bid > pendingSu){
               order_type = OP_SELLSTOP;
            }
            
         }
         
         Sleep(1000);

         bool result = OrderSend(Symbol(),
										order_type,
										Lots,
										NormalizeDouble(pendingSu,Digits),
										NormalizeDouble(slippage,Digits),
										NormalizeDouble(slSu,Digits),
										NormalizeDouble(tpSu,Digits),
										"",
										0,
										TimeCurrent()+86400,
										CLR_NONE
										);
											

         Sleep(1000);
         
         if(!result){
            Alert("failed trade on ",Symbol());
         }else{
            /*DELETE FIBO OBJECT*/
            do{
               ObjectDelete(ChartID(), objT);
               Sleep(500);
            }while(ObjectFind(ChartID(), objT)==0);
            
            string pendingType="pending SHIT set on";
            
            if(order_type==OP_BUYSTOP || order_type==OP_BUYLIMIT){
               pendingType="pending BUY set on ";
            }else if(order_type==OP_SELLSTOP || order_type==OP_SELLLIMIT){
               pendingType="pending SELL set on ";
            }
            
            string msg = pendingType+Symbol()+"\n\n with Lotsize: "+Lots+"\n SL: "
                         + MathMax( NormalizeDouble( (slSu-pendingSu), Digits) , NormalizeDouble( (pendingSu - slSu), Digits))
                         +"\n with TP: "
                         + MathMax( NormalizeDouble( (tpSu-pendingSu), Digits) , NormalizeDouble( (pendingSu - tpSu), Digits))
                         +"\n on " + TimeCurrent();
           
            
            SendMail(AccountCompany(), msg);
            Sleep(500);
         } 
       
         
         
      
      }
      
      
   
   }    
   return(0);
}




void OnTick(){

if(AccountNumber()!=10638064){
   return;/*anti piracy AccountNumber()!=692440 OANDA {*/
}

   if(!wallExists()){
      /*execute motherfucking pending code here*/
      //Comment("no more walls, proceed pending");
      plotPending();
   }else{
      //Comment("walls awaiting to be destroyed");
   }
   
   if(IsNewBar()){   
 



      if(Period()<PERIOD_H4){
         //Alert(Symbol()+" should be on H4 TimeFrame Above");
         Comment(Symbol()+" should be on H4 TimeFrame Above");
         Print(Symbol()+" should be on H4 TimeFrame Above");
      }
      
      for(int i = ObjectsTotal()-1; i>=0; i--){
      
         string objName  = ObjectName(i);
                
         if( ObjectType(objName)!=OBJ_RECTANGLE ) continue;
   
         double topPrice = MathMax(ObjectGet(objName,OBJPROP_PRICE1), ObjectGet(objName,OBJPROP_PRICE2));
         double botPrice = MathMin(ObjectGet(objName,OBJPROP_PRICE1), ObjectGet(objName,OBJPROP_PRICE2));
         
         int objColor = ObjectGet(objName,OBJPROP_COLOR);
         
         if(topPrice>Bid && Bid>botPrice && objColor!=0){
            string title = AccountCompany();
            string msg = Symbol()+" is on the required level";         
            /*EMAIL ME*/
            Comment("Junjun emailed");
            SendMail(AccountCompany(), msg);
         }
      
      }
      
      
      
      
    }/*END TICK*/
    
}
//+------------------------------------------------------------------+
