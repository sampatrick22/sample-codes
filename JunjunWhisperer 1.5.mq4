//+------------------------------------------------------------------+
//|                                              JunjunWhisperer.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                           https://www.kamote.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
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
         
         double Lots    = 0.25;
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
            
            } 
       
         
         
      
      }
      
      
   
   }    
   return(0);
}




void OnTick(){

if(AccountNumber()!=692440 && AccountNumber()!=10638064){
   return;/*anti piracy {*/
}

   wallExists();
   
   if(IsNewBar()){
//      Comment("");     
 
      if(!wallExists()){
         /*execute motherfucking pending code here*/
         //Comment("no more walls, proceed pending");
         plotPending();
      }else{
         //Comment("walls awaiting to be destroyed");
      }


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
