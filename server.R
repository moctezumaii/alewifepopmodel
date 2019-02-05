library(shiny)
library(shinyWidgets)
shinyServer( 
  function(input, output, session){
    hideTab("tabs","Comparative model")
    hideTab("tabs","test101")
    observeEvent(input$app,{
      updateTabsetPanel(session, "tabs", "test101")
    })
    
    
    
    observeEvent(input$loadbutton1,{
      updateTabsetPanel(session, "tabs", "Comparative model")
    })
    
    #Libraries needed:
    library(tidyverse)
    library(reshape2)
    library(scales)
    library(ggplot2)
    
    
    
    #############################
    #############FUNCTION#########
    ##############################
    Full_Model <- function (ProbMature, ProbSpawn, alpha, RPA, FecSlope, FecIntercept, MFRatio, ndams, UpPassAdult, DnPassAdult,
                            DnPassJuv, HabitatSize, InstOcean, InstSpawn, JuvFWRes, SpawnFWRes, SpawnOceanRes, MassAtAge,
                            nYears, Escapement, InitialOceanDist, PropSpawners, InitialSpawnDist) {
      
      ##Equation for upstream passage:
      YOYPA <- floor(RPA / ((1-0.35095) * (1-0.4771) * (1-0.4771)))
      
      HSRev <- rev(HabitatSize)
      Totals <- cumsum(HSRev)
      TT <- rev(Totals)
      Dist_US <- (1-(HabitatSize / TT))
      
      # UpPassAdultHU <- vector(mode = 'numeric', length = ndams)
      DnSurvAdultHU <- vector(mode = 'numeric', length = ndams)
      DSYOYSurvHU <- vector(mode = 'numeric', length = ndams)
      DSYOYSurvHU <- cumprod(DnPassJuv)
      DnSurvAdultHU <- cumprod(DnPassAdult)
      
      #Ocean Mortality
      IntervalOceanMort <- (1-exp(-InstOcean))
      YOYOceanMort <- (1-exp(-InstOcean*JuvFWRes))
      # 
      # #Spawning Survival
      IntervalSpawnFWSurv <- (exp(-InstSpawn * SpawnFWRes))
      IntervalSpawnOceanSurv <- (exp(-InstOcean * SpawnOceanRes))
      # 
      # #Initial population distribution
      Initial <- Escapement / PropSpawners
      
      ####Population Framework####
      ####Create empty lists and Dataframes####
      ##Keep in mind that year 1 is the year with all the initial values, and year 2 is when the forward-projection starts##
      ##Ocean Population##
      Years <- c(1:nYears)
      
      OceanAge <- c(1:9)
      list_of_OceanAbund <- list()
      list_of_OceanMort <- list()
      list_of_OceanSurv <- list()
      for (k in (OceanAge)) {
        list_of_OceanAbund[[k]] <- vector(mode = 'numeric', length = nYears)
        list_of_OceanMort[[k]] <- vector(mode = 'numeric', length = nYears)
        list_of_OceanSurv[[k]] <- vector(mode = 'numeric', length = nYears)
      }
      
      Ocean_Abund <- data.frame(Years, list_of_OceanAbund)
      colnames(Ocean_Abund) <- c("Year", "OceanAbundYOY", "OceanAbundYr1", "OceanAbundYr2", "OceanAbundYr3", "OceanAbundYr4", 
                                 "OceanAbundYr5", "OceanAbundYr6", "OceanAbundYr7", "OceanAbundYr8")
      Ocean_Mort <- data.frame(Years, list_of_OceanMort)
      colnames(Ocean_Mort) <- c("Year", "OceanMortYOY", "OceanMortYr1", "OceanMortYr2", "OceanMortYr3", "OceanMortYr4",
                                "OceanMortYr5", "OceanMortYr6", "OceanMortYr7", "OceanMortYr8")
      Ocean_Surv <- data.frame(Years, list_of_OceanSurv)
      colnames(Ocean_Surv) <- c("Year", "OceanSurvYOY", "OceanSurvYr1", "OceanSurvYr2", "OceanSurvYr3", "OceanSurvYr4",
                                "OceanSurvYr5", "OceanSurvYr6", "OceanSurvYr7", "OceanSurvYr8")
      
      
      ##Spawning Population##
      SpawnAge <- c(1:6)
      list_of_Abund <- list()
      list_of_mort <- list()
      list_of_surv <- list()
      list_spn_ocean <- list()
      for (k in SpawnAge){
        list_of_Abund[[k]] <- vector(mode = 'numeric', length = nYears)
        list_of_mort[[k]] <- vector(mode = 'numeric', length = nYears)
        list_of_surv[[k]] <- vector(mode = 'numeric', length = nYears)
        list_spn_ocean[[k]] <- vector(mode = 'numeric', length = nYears)
      }
      
      SpawnAbund <- data.frame(Years, list_of_Abund)
      colnames(SpawnAbund) <- c("Year", "SpawnYr3", "SpawnYr4", "SpawnYr5", "SpawnYr6", "SpawnYr7", "SpawnYr8")
      
      SpawnMort <- data.frame(Years, list_of_mort)
      colnames(SpawnMort) <- c("Year", "SpawnMortYr3", "SpawnMortYr4", "SpawnMortYr5", "SpawnMortYr6", "SpawnMortYr7", "SpawnMortYr8")
      
      SpawnSurv <- data.frame(Years, list_of_surv)
      colnames(SpawnSurv) <- c("Year", "SpawnSurvYr3", "SpawnSurvYr4", "SpawnSurvYr5", "SpawnSurvYr6", "SpawnSurvYr7", "SpawnSurvYr8")
      
      Spawn_Ocean <- data.frame(Years, list_spn_ocean)
      colnames(Spawn_Ocean) <- c("Year", "Spawn3_Ocean4", "Spawn4_Ocean5", "Spawn5_Ocean6", "Spawn6_Ocean7", "Spawn7_Ocean8", "Total Death")
      
      #Make list to hold the next set of lists
      results <- list()
      #habitat-specific lists: create a list for each dam
      for (b in 1:ndams){
        list_of_EnteringHU <- list()
        list_of_StayHU <- list()
        list_of_MovingToNextHU <- list()
        list_of_SpawningMortHU <- list()
        list_of_EggProdHU <- list()
        list_of_DSMortHU <- list()
        list_of_DSSurvHU <- list()
        for (k in SpawnAge){
          list_of_EnteringHU[[k]] <- vector(mode = 'numeric', length = nYears)
          list_of_StayHU[[k]] <- vector(mode = 'numeric', length = nYears)
          list_of_MovingToNextHU[[k]] <- vector(mode = 'numeric', length = nYears)
          list_of_SpawningMortHU[[k]] <- vector(mode = 'numeric', length = nYears)
          list_of_EggProdHU[[k]] <- vector(mode = 'numeric', length = nYears)
          list_of_DSMortHU[[k]] <- vector(mode = 'numeric', length = nYears)
          list_of_DSSurvHU[[k]] <- vector(mode = 'numeric', length = nYears)
        }
        
        #create dataframes from lists and column names:
        
        EnteringHU <- data.frame(Years, list_of_EnteringHU)
        colnames(EnteringHU) <- c("Year", "EnterHUYr3", "EnterHUYr4", "EnterHUYr5", "EnterHUYr6", "EnterHUYr7", "EnterHUYr8")  
        
        StayHU <- data.frame(Years, list_of_StayHU)
        colnames(StayHU) <- c("Year", "StayHUYr3", "StayHUYr4", "StayHUYr5", "StayHUYr6", "StayHUYr7", "StayHUYr8")
        
        MoveToNextHU <- data.frame(Years, list_of_MovingToNextHU)
        colnames(MoveToNextHU) <- c("Year", "MoveToNextHUYr3", "MoveToNextHUYr4", "MoveToNextHUYr5", "MoveToNextHUYr6",
                                    "MoveToNextHUYr7", "MoveToNextHUYr8")
        
        SpawnMortHU <- data.frame(Years, list_of_SpawningMortHU)
        colnames(SpawnMortHU) <- c("Year", "SpawnMortHUYr3", "SpawnMortHUYr4", "SpawnMortHUYr5", "SpawnMortHUYr6", "SpawnMortHUYr7",
                                   "SpawnMortHUYr8")
        
        EggProdHU <- data.frame(Years, list_of_EggProdHU)
        colnames(EggProdHU) <- c("Year", "EggProdHUYr3", "EggProdHUYr4", "EggProdHUYr5", "EggProdHUYr6", "EggProdHUYr7",
                                 "EggProdHUYr8")
        
        DSMortHU <- data.frame(Years, list_of_DSMortHU)
        colnames(DSMortHU) <- c("Year", "DSMortHUYr3", "DSMortHUYr4", "DSMortHUYr5", "DSMortHUYr6", "DSMortHUYr7", "DSMortHUYr8")
        
        DSSurvHU <- data.frame(Years, list_of_DSSurvHU)
        colnames(DSSurvHU) <- c("Year", "DSSurvHUYr3", "DSSurvHUYr4", "DSSurvHUYr5", "DSSurvHUYr6", "DSSurvHUYr7", "DSSurvHUYr8")
        
        results[[b]]<-list(EnteringHU = EnteringHU, StayHU = StayHU, MoveToNextHU = MoveToNextHU, SpawnMortHU = SpawnMortHU, 
                           EggProdHU = EggProdHU, DSMortHU = DSMortHU, DSSurvHU = DSSurvHU)
      }
      
      #Create separate data frames for recruits (BH) and total eggs produced 
      temp <- ndams+1
      BH <- data.frame(matrix(ncol = temp, nrow = nYears))
      colnames(BH) <- c("Year",(lapply(1:ndams, function(x){paste0("BH", x)})))
      BH[,1] <- c(1:nYears)
      
      TotalEggs <- data.frame(matrix(ncol = temp, nrow = nYears))
      colnames(TotalEggs) <- c("Year", (lapply(1:ndams, function(x){paste0("TotalEggs",x)})))
      TotalEggs[,1] <- c(1:nYears)
      
      ####Define Initial values in Population Framework####
      ##These are the values in row 1, which are calculated differently than in rows 2:nrow
      
      Year <- c("YOY", "Yr1", "Yr2", "Yr3", "Yr4", "Yr5", "Yr6", "Yr7", "Yr8")
      Initial_Ocean_Pop <- (data.frame(Age = Year, OceanAb = floor(Initial * InitialOceanDist)))
      
      #Now create dataframe for spawning population:
      Spawn_Year <- c("SpawnYr3", "SpawnYr4", "SpawnYr5", "SpawnYr6", "SpawnYr7", "SpawnYr8")
      Initial_Spawning_Pop <- data.frame(SpawnAge = Spawn_Year, SpawnAb = floor((Escapement * InitialSpawnDist)))
      
      #Set initial parameters for each row in ocean population and spawning population (THIS IS YEAR 1), and calculate all 
      #further values based on these abundances so can carry forward to next year
      
      ####Initial values for Ocean Population####
      #Ocean Abundance:
      Ocean_Abund[1,]$OceanAbundYOY <- Initial_Ocean_Pop[1,2]
      Ocean_Abund[1,3:10] <- Initial_Ocean_Pop[2:9,2]
      
      #Ocean Mort:
      Ocean_Mort[1,]$OceanMortYOY <- floor((Ocean_Abund[1,]$OceanAbundYOY * YOYOceanMort))
      Ocean_Mort[1,3:10] <- floor((Ocean_Abund[1,3:10] * IntervalOceanMort))
      
      #Ocean Survival:
      Ocean_Surv[1,]$OceanSurvYOY <- floor((Ocean_Abund[1,]$OceanAbundYOY * (1-YOYOceanMort)))
      Ocean_Surv[1,]$OceanSurvYr1 <- floor((Ocean_Abund[1,]$OceanAbundYr1 * (1 - IntervalOceanMort)))
      Ocean_Surv[1,4:10] <- floor((Ocean_Abund[1,4:10] * (1-IntervalOceanMort) * (1 - ProbMature)))
      
      ####Spawning Population####
      #First define initial spawner abundance so can calculate habitat-specific abundances
      SpawnAbund[1,2:7] <- Initial_Spawning_Pop[,2]
      ##Next, to calculate values for mortality and survival dataframes, first need to determine habitat-specific abundances##
      
      ####Habitat-Specific equations for row 1####
      if (ndams == 1){
        results[[1]]$EnteringHU[1,2:7] <- floor((SpawnAbund[1,2:7] * ProbSpawn * UpPassAdult[1]))
      } else {
        #This calculated the correct number of fish entering HU1
        results[[1]]$EnteringHU[1,2:7] <- floor((SpawnAbund[1,2:7] * ProbSpawn * UpPassAdult[1]))
      }
      for (c in 1:ndams){
        #This is the distribution for fish that continue upstream when motivation is driven by habitat availability
        
        
        #This is the number of fish that successfully pass the dam into the next HU
        if (c!=ndams){
          results[[c]]$MoveToNextHU[1,2:7] <- floor((results[[c]]$EnteringHU[1,2:7] * Dist_US[c]))
          
          results[[c+1]]$EnteringHU[1,2:7] <- floor((results[[c]]$MoveToNextHU[1,2:7] * UpPassAdult[c+1])) 
          
          results[[c]]$StayHU[1,2:7] <- floor(((results[[c]]$EnteringHU[1,2:7] - results[[c]]$MoveToNextHU[1,2:7]) + 
                                                 (results[[c]]$MoveToNextHU[1,2:7] - results[[c+1]]$EnteringHU[1,2:7])))
        } else {
          
          results[[c]]$StayHU[1,2:7] <- floor(((results[[c]]$EnteringHU[1,2:7])))
        }
        
        #Now define spawning mortality:
        results[[c]]$SpawnMortHU[1,2:7] <- floor((results[[c]]$StayHU[1,2:7] * (1-IntervalSpawnFWSurv)))
        
        #Define egg production:
        results[[c]]$EggProdHU[1,2:7] <- floor((((results[[c]]$StayHU[1,2:7] * IntervalSpawnFWSurv * ProbSpawn) * MFRatio) * 
                                                  ((FecSlope*MassAtAge) - FecIntercept)))
        
        #Define DS Adult Mortality (I think this may be defined incorrectly, I"m not sure IntervalSpawnFWSurv should be in equation like that):
        #Should DnSurvAdultHU[c
        results[[c]]$DSMortHU[1,2:7] <- floor((results[[c]]$StayHU[1,2:7] * (1-(IntervalSpawnFWSurv * DnSurvAdultHU[c]))))
        
        #Define DS Adult Survival:
        results[[c]]$DSSurvHU[1,2:7] <- floor((results[[c]]$StayHU[1,2:7] * IntervalSpawnFWSurv * DnSurvAdultHU[c]))  
        
      }
      
      #Define total egg production and recruitment for first row for each HU
      temp <- ndams+1
      TotalEggs[1,2:temp] <- lapply(1:ndams, function(x){rowSums(results[[x]]$EggProdHU[1,2:7])})
      #Define initial row of YOY produced for each HU:
      ##There was a comma missing in the Stella model for SP, but now the difference is even larger! FML
      #Though the first row is the same, but after that the difference becomes larger
      BH[1,2:temp] <- floor((alpha * TotalEggs[1,2:temp]) / 
                              (1 + ((alpha * TotalEggs[1,2:temp]) / 
                                      (HabitatSize * YOYPA))))
      
      ####Calculate Total Spawning mortality, survival to next age class, and Spawn_Ocean for row 1####
      #Spawning Mortality:
      Spn <- data.frame(matrix(nrow = 6, ncol = ndams))
      for (d in 1:ndams){
        Spn[d] <- unlist(results[[d]]$DSSurvHU[1,2:7])
      }
      SpawnSurv[1,2:6] <- floor((rowSums(Spn[1:5,1:ndams])*IntervalSpawnOceanSurv))
      #Added this so SpawnSurv Yr 8 = Total death in Stella, but didn't make a different in Spawner Abund, which makes sense
      SpawnSurv[1,7] <- floor(rowSums(Spn[6,1:ndams]))
      
      #Fish that mature but do not spawn (small percentage of spawners)
      Spawn_Ocean[1,2:7] <- floor((SpawnAbund[1,2:7] * IntervalSpawnFWSurv * IntervalSpawnOceanSurv * (1 - ProbSpawn)))
      
      #Mortality related to spawning
      SpawnMort[1,2:7] <- floor(SpawnAbund[1,2:7] - Spawn_Ocean[1,2:7] - SpawnSurv[1,2:7])
      
      ####Maturing Fish####
      #first create dataframe for maturing to spawning population:
      list_of_maturing <- list()
      for (k in (SpawnAge)) {
        list_of_maturing[[k]] <- vector(mode = 'numeric', length = nYears)
      }
      
      Maturing <- data.frame(Years, list_of_maturing)
      colnames(Maturing) <- c("Year", "Mature2", "Mature3", "Mature4", "Mature5", "Mature6", "Mature7")
      
      #Define first row for maturing fish:
      Maturing[1,2:7] <- floor(Ocean_Abund[1,4:9] * ProbMature * (1 - IntervalOceanMort))
      
      
      ####Now need to define the rest of the rows (Years 2 to nYears)####
      for (l in 2:nYears) {
        #First define recruitment based on previous year
        temp <- ndams + 1
        Recruit <- floor(data.frame(mapply(`*`, BH[,2:temp], DSYOYSurvHU)))
        Recruit$TotalRecruits <- Recruit %>% select(contains("BH")) %>% rowSums(na.rm = TRUE)
        #Define Ocean Population based on previous year's abundances:
        Ocean_Abund[l,]$OceanAbundYOY <- floor(Recruit$TotalRecruits[l-1])
        Ocean_Abund[l,]$OceanAbundYr1 <- Ocean_Surv[l-1,]$OceanSurvYOY
        Ocean_Abund[l,]$OceanAbundYr2 <- Ocean_Surv[l-1,]$OceanSurvYr1
        Ocean_Abund[l,]$OceanAbundYr3 <- Ocean_Surv[l-1,]$OceanSurvYr2
        Ocean_Abund[l,]$OceanAbundYr4 <- (Ocean_Surv[l-1,]$OceanSurvYr3 + Spawn_Ocean[l-1,]$Spawn3_Ocean4)
        Ocean_Abund[l,]$OceanAbundYr5 <- (Ocean_Surv[l-1,]$OceanSurvYr4 + Spawn_Ocean[l-1,]$Spawn4_Ocean5)
        Ocean_Abund[l,]$OceanAbundYr6 <- (Ocean_Surv[l-1,]$OceanSurvYr5 + Spawn_Ocean[l-1,]$Spawn5_Ocean6)
        Ocean_Abund[l,]$OceanAbundYr7 <- (Ocean_Surv[l-1,]$OceanSurvYr6 + Spawn_Ocean[l-1,]$Spawn6_Ocean7)
        Ocean_Abund[l,]$OceanAbundYr8 <- (Ocean_Surv[l-1,]$OceanSurvYr7 + Spawn_Ocean[l-1,]$Spawn7_Ocean8)
        
        #Ocean Mort:
        Ocean_Mort[l,]$OceanMortYOY <- floor((Ocean_Abund[l,]$OceanAbundYOY * YOYOceanMort))
        Ocean_Mort[l,3:10] <- floor((Ocean_Abund[l,3:10] * IntervalOceanMort))
        
        #Ocean Survival:
        Ocean_Surv[l,]$OceanSurvYOY <- floor((Ocean_Abund[l,]$OceanAbundYOY * (1-YOYOceanMort)))
        Ocean_Surv[l,]$OceanSurvYr1 <- floor((Ocean_Abund[l,]$OceanAbundYr1 * (1 - IntervalOceanMort)))
        Ocean_Surv[l,4:10] <- floor((Ocean_Abund[l,4:10] * (1-IntervalOceanMort) * (1 - ProbMature)))
        
        #Define SpawnAbund Based on previous year's abundances:
        SpawnAbund[l,]$SpawnYr3 <- Maturing[l-1,]$Mature2
        SpawnAbund[l,]$SpawnYr4 <- Maturing[l-1,]$Mature3 + SpawnSurv[l-1,]$SpawnSurvYr3
        SpawnAbund[l,]$SpawnYr5 <- Maturing[l-1,]$Mature4 + SpawnSurv[l-1,]$SpawnSurvYr4
        SpawnAbund[l,]$SpawnYr6 <- Maturing[l-1,]$Mature5 + SpawnSurv[l-1,]$SpawnSurvYr5
        SpawnAbund[l,]$SpawnYr7 <- Maturing[l-1,]$Mature6 + SpawnSurv[l-1,]$SpawnSurvYr6
        SpawnAbund[l,]$SpawnYr8 <- Maturing[l-1,]$Mature7 + SpawnSurv[l-1,]$SpawnSurvYr7
        
        #Now define habitat-specific values
        if (ndams == 1){
          results[[1]]$EnteringHU[l,2:7] <- floor((SpawnAbund[l,2:7] * ProbSpawn * UpPassAdult[1]))
        } else {
          results[[1]]$EnteringHU[l,2:7] <- floor((SpawnAbund[l,2:7] * ProbSpawn * UpPassAdult[1]))
        }
        for (c in 1:ndams){
          
          
          
          if (c!=ndams){
            results[[c]]$MoveToNextHU[l,2:7] <- floor((results[[c]]$EnteringHU[l,2:7] * Dist_US[c])) 
            
            results[[c+1]]$EnteringHU[l,2:7] <- floor((results[[c]]$MoveToNextHU[l,2:7] * UpPassAdult[c+1]))
            
            results[[c]]$StayHU[l,2:7] <- floor(((results[[c]]$EnteringHU[l,2:7] - results[[c]]$MoveToNextHU[l,2:7]) + 
                                                   (results[[c]]$MoveToNextHU[l,2:7] - results[[c+1]]$EnteringHU[l,2:7])))
          } else{
            
            results[[c]]$StayHU[l,2:7] <- floor(((results[[c]]$EnteringHU[l,2:7])))
            
          }
          
          
          #Now define spawning mortality:
          results[[c]]$SpawnMortHU[l,2:7] <- floor((results[[c]]$StayHU[l,2:7] * (1-IntervalSpawnFWSurv)))
          
          #Define egg production:
          results[[c]]$EggProdHU[l,2:7] <- floor((((results[[c]]$StayHU[l,2:7] * IntervalSpawnFWSurv * ProbSpawn) * MFRatio) * 
                                                    ((FecSlope*MassAtAge) - FecIntercept)))
          
          #Define DS Adult Mortality (I think this may be define incorrectly):
          results[[c]]$DSMortHU[l,2:7] <- floor((results[[c]]$StayHU[l,2:7] * (1-(IntervalSpawnFWSurv * DnSurvAdultHU[c]))))
          
          #Define DS Adult Survival:
          results[[c]]$DSSurvHU[l,2:7] <- floor((results[[c]]$StayHU[l,2:7] * IntervalSpawnFWSurv * DnSurvAdultHU[c]))  
        }
        
        #Total Eggs and Recruits out of ndams loop b/c don't need to cycle through, but still in nYears loop because need by calculate by row!   
        TotalEggs[l,2:temp] <- lapply(1:ndams, function(x){rowSums(results[[x]]$EggProdHU[l,2:7])})
        #Define initial row of YOY produced for each HU:
        BH[l,2:temp] <- floor(((alpha * TotalEggs[l,2:temp]) / 
                                 (1 + ((alpha * TotalEggs[l,2:temp]) / 
                                         (HabitatSize * YOYPA)))))
        
        #Define mortality as the sum of each age class from each habitat unit:
        #First create dataframes to hold information from each age class:
        StayYr3 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        StayYr4 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        StayYr5 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        StayYr6 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        StayYr7 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        StayYr8 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        #Then select data for each age class from "StayHU":
        for (x in 1:ndams){
          unlist(results[[x]]$StayHU)
          StayYr3[,x] <- select(results[[x]]$StayHU, matches("StayHUYr3"))
          StayYr4[,x] <- select(results[[x]]$StayHU, matches("StayHUYr4"))
          StayYr5[,x] <- select(results[[x]]$StayHU, matches("StayHUYr5"))
          StayYr6[,x] <- select(results[[x]]$StayHU, matches("StayHUYr6"))
          StayYr7[,x] <- select(results[[x]]$StayHU, matches("StayHUYr7"))
          StayYr8[,x] <- select(results[[x]]$StayHU, matches("StayHUYr8"))
        }
        
        #Now calculate survival:
        #First create dataframes for each age class:
        SpawnYr3 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        SpawnYr4 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        SpawnYr5 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        SpawnYr6 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        SpawnYr7 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        SpawnYr8 <- data.frame(matrix(ncol = ndams, nrow = nYears))
        #Then select data from each age class from "DSSurvHU":
        for (x in 1:ndams){
          unlist(results[[x]]$DSSurvHU)
          SpawnYr3[,x] <- select(results[[x]]$DSSurvHU, matches("DSSurvHUYr3"))
          SpawnYr4[,x] <- select(results[[x]]$DSSurvHU, matches("DSSurvHUYr4"))
          SpawnYr5[,x] <- select(results[[x]]$DSSurvHU, matches("DSSurvHUYr5"))
          SpawnYr6[,x] <- select(results[[x]]$DSSurvHU, matches("DSSurvHUYr6"))
          SpawnYr7[,x] <- select(results[[x]]$DSSurvHU, matches("DSSurvHUYr7"))
          SpawnYr8[,x] <- select(results[[x]]$DSSurvHU, matches("DSSurvHUYr8"))
        }
        #Then calculate Survival:
        SpawnSurv[l,2] <- floor((rowSums(SpawnYr3[l,])*IntervalSpawnOceanSurv))
        SpawnSurv[l,3] <- floor((rowSums(SpawnYr4[l,])*IntervalSpawnOceanSurv))
        SpawnSurv[l,4] <- floor((rowSums(SpawnYr5[l,])*IntervalSpawnOceanSurv))
        SpawnSurv[l,5] <- floor((rowSums(SpawnYr6[l,])*IntervalSpawnOceanSurv))
        SpawnSurv[l,6] <- floor((rowSums(SpawnYr7[l,])*IntervalSpawnOceanSurv))
        SpawnSurv[l,7] <- floor((rowSums(SpawnYr8[l,])*IntervalSpawnOceanSurv))
        
        #Calculate the number of fish that don't spawn but return to the ocean
        Spawn_Ocean[l,2:7] <- floor((SpawnAbund[l,2:7] * IntervalSpawnFWSurv * IntervalSpawnOceanSurv * (1 - ProbSpawn)))
        
        #Calculate spawning mortality
        SpawnMort[l,2:7] <- floor(SpawnAbund[l,2:7] - Spawn_Ocean[l, 2:7] - SpawnSurv[l, 2:7])
        
        #Maturing Fish:
        Maturing[l,]$Mature2 <- floor((Ocean_Abund[l,]$OceanAbundYr2 * ProbMature[1] * (1 - IntervalOceanMort)))
        Maturing[l,]$Mature3 <- floor((Ocean_Abund[l,]$OceanAbundYr3 * ProbMature[2] * (1 - IntervalOceanMort)))
        Maturing[l,]$Mature4 <- floor((Ocean_Abund[l,]$OceanAbundYr4 * ProbMature[3] * (1 - IntervalOceanMort)))
        Maturing[l,]$Mature5 <- floor((Ocean_Abund[l,]$OceanAbundYr5 * ProbMature[4] * (1 - IntervalOceanMort)))
        Maturing[l,]$Mature6 <- floor((Ocean_Abund[l,]$OceanAbundYr6 * ProbMature[5] * (1 - IntervalOceanMort)))
        Maturing[l,]$Mature7 <- floor((Ocean_Abund[l,]$OceanAbundYr7 * ProbMature[6] * (1 - IntervalOceanMort)))
        
      }
      
      ####Make list of ouputs to put into the function####
      List_of_Outputs <- list(Recruitment = BH, Maturing = Maturing, Ocean_Abund = Ocean_Abund, Ocean_Mort = Ocean_Mort, 
                              Ocean_Surv = Ocean_Surv, Spawn_Ocean = Spawn_Ocean, SpawnAbund = SpawnAbund, SpawnMort = SpawnMort, 
                              SpawnSurv = SpawnSurv,HUs=results)
      
      return(List_of_Outputs)
    }
    
    #########################
    
    
    
    adamnriverfunction<-function(){
      if (input$river==1){
        ndams<-(4)
       
        tmp1<-as.numeric(as.character(c(input$MTAU1,input$WLAU1,input$GFAU1,input$SPAU1)))
        tmp1<-tmp1/100
        tmp2<-as.numeric(as.character(c(input$MTAD1,input$WLAD1,input$GFAD1,input$SPAD1 )) )
        tmp2<-tmp2/100  
          
        tmp3<-as.numeric(as.character(c(input$MTJD1,input$WLJD1,input$GFJD1,input$SPJD1)))
        tmp3<-tmp3/100
        hab<-as.numeric(c(252, 1174, 23212, 36209))
        tmp4<-list(ndams,tmp1,tmp2,tmp3,hab)  
        return(tmp4) 
        
      } else
      {
        ndams<-as.numeric(ans())
        tmp1<-paste0("c(",paste0("input[['AU",1:ndams,"']]",collapse=', '),")")
        tmp1<-eval(parse(text = tmp1))
        tmp1<-tmp1/100
        tmp2<-paste0("c(",paste0("input[['AD",1:ndams,"']]",collapse=', '),")")
        tmp2<-eval(parse(text = tmp2))
        tmp2<-tmp2/100
        tmp3<-paste0("c(",paste0("input[['JD",1:ndams,"']]",collapse=', '),")")
        tmp3<-eval(parse(text = tmp3))
        tmp3<-tmp3/100
        hab<-paste0("c(",paste0("input[['number",1:ndams,"']]",collapse=', '),")")
        hab<-eval(parse(text = hab))
        hab<-as.numeric(hab)
       tmp4<-list(ndams,tmp1,tmp2,tmp3,hab)  
      return(tmp4) 
        
      }
   
    
    }
    
    
    rivres<-eventReactive(input$runthemodel,{
     adamnriverfunction()
    }) 
    nyears<-eventReactive(input$runthemodel,{
      input$ayears
    })
    
    ####IF we make a more complex version of the app this should be changed from hard-coding to soft-coding with variables defined in the first
    #lines if the server, while creating alternative names for each 
   RUN<-eventReactive(input$runthemodel,{
     Full_Model(ProbMature=c(0.35, 0.51, 0.955, 1.0, 1.0, 1.0), 

     #change this values and take them outside of the function
   
                ProbSpawn = rep(0.95, times = 6), 
               alpha=0.0019, 
               RPA=582.659,
               FecSlope=871.72, 
               FecIntercept=50916,  
               MFRatio = 0.50,  
               ndams = rivres()[[1]],
               UpPassAdult = rivres()[[2]], 
               DnPassAdult = rivres()[[3]],
               DnPassJuv = rivres()[[4]], 
               HabitatSize = rivres()[[5]],
               InstOcean = 0.648365, 
               InstSpawn = 2.3913, JuvFWRes = 0.66667 , SpawnFWRes =0.25, 
               SpawnOceanRes = 0.75, MassAtAge = c(144, 186, 209, 244, 277, 353), nYears = nyears(),
               Escapement = 1000, InitialOceanDist = c(0.60, 0.24, 0.093, 0.0238, 0.0076, 0.000423, 0.000148, 0.0000535, 0.0000193), 
               PropSpawners = 0.0378, InitialSpawnDist = c(0.33877, 0.31471, 0.22514, 0.08143, 0.02937, 0.01059) 
               #Dist_US =(1-(rivres()[[5]]/(rev(cumsum(rev(rivres()[[5]]))))))
     )   

   
     })
   
   
  ###years is softcoded
   functionforplot<-function(){
     ColNames <- (sapply(1:rivres()[[1]], function(x){
       paste0("TotalHU", x)
     }))
     Totals2 <- as.data.frame(sapply(1:rivres()[[1]], function(x){
       rowSums(RUN()[[length(RUN())]][[x]]$StayHU)
     }))
     colnames(Totals2) <- ColNames
     Totals2 <- mutate(Totals2, Year = c(1:nyears()))
     
     #Change from wide to long format for plotting
     Total_Long = melt(Totals2, id = c("Year"))
     Total_Long$Year = as.integer(Total_Long$Year)
     return(Total_Long)
   }  
   
   
#    
output$testtable1<-renderPlot({
     withProgress(message = "LOADING" , detail="please wait", style="notification", value=NULL, {
  
#
# #  #str(Total_Long)
#
#
#    # ##Code for plot showing the theoretical abundance through time for all four habitat units:##
  ggplot(functionforplot()) +
    geom_line(aes(x = Year, y = value, color = variable), size = 1) +
    ylab("Theoretical Abundance") + theme_classic() +
    scale_color_manual(values = c("darkorange2", "chocolate4", "blue4", "darkgoldenrod", "deepskyblue4", "darkgreen"),
                       labels = c("Dam 1", "Dam 2", "Dam 3", "Dam 4", "Dam 5", "Dam 6"), name = "Site") +
    scale_y_continuous(label = comma) +
    theme(axis.text = element_text(color = "black", size = 12), axis.title.x = element_text(size = 14), axis.title.y =
            element_text(size = 14), legend.text = element_text(size = 12), legend.title = element_text(size = 14))
     })
})

# 
#      output$testtable1<-renderTable({
#       rivres()
#    })
   
   
   
    # output$plot1<-renderPlot({
    #   ### this is hard coded for 4 dams, needs to be changed to soft coding with paramete ndams affecting it
    #   #probably will need to call an extra function once it is soft coded
    #   
    #   HU1 <- mutate(RUN$StayHU1, Total1 = StayHU1Yr3 + StayHU1Yr4 + StayHU1Yr5 + StayHU1Yr6 + StayHU1Yr7 + StayHU1Yr8)
    #   HU2 <- mutate(RUN$StayHU2, Total2 = StayHU2Yr3 + StayHU2Yr4 + StayHU2Yr5 + StayHU2Yr6 + StayHU2Yr7 + StayHU2Yr8)
    #   HU3 <- mutate(RUN$StayHU3, Total3 = StayHU3Yr3 + StayHU3Yr4 + StayHU3Yr5 + StayHU3Yr6 + StayHU3Yr7 + StayHU3Yr8)
    #   HU4 <- mutate(RUN$StayHU4, Total4 = StayHU4Yr3 + StayHU4Yr4 + StayHU4Yr5 + StayHU4Yr6 + StayHU4Yr7 + StayHU4Yr8)
    #   
    #   Total_Abund <-  cbind(HU1$Total1, HU2$Total2, HU3$Total3, HU4$Total4, HU1$Year)
    #   colnames(Total_Abund) <- c("TotalHU1", "TotalHU2", "TotalHU3", "TotalHU4", "Year")
    #   #It needs to be a dataframe for plotting
    #   Total_Abund <- data.frame(Total_Abund)
    #   Total = melt(Total_Abund, id = c("Year"))
    #   Total$Year = as.integer(Total$Year) 
    #   
    #   
    #   
    # })
    # output$plot2<-renderPlot({
    #  
    #   plot(input$MTAU2,input$MTAD2)
    # })
    ans<-reactive({input$test})
    
    output$see<-renderUI({
      tmp<-ans()
      if (input$river==2)   {
        D<-sapply(1:tmp, function(i){paste0("damlabel",i)})
        N<-sapply(1:tmp, function(i){paste0("number",i)})
        output = tagList()
        for (i in 1:ans()){
          output[[i]] = tagList()
          output[[i]][[1]]=column(6,
                                 textInput(D[i], label=paste0("Name of dam #",i),value=paste0("Dam ",i)))
          output[[i]][[2]]=column(6,
                                  numericInput(N[i], label=paste0("Available habitat (acres) dam #",i),value=200,min=1))
          #nameofdam<-paste("Name of dam #",i,sep=" ")
          #nameofinput<-paste("dam#",i,sep="")
          #textInput(nameofinput, label=nameofdam, value = nameofdam)
          
        }
      output
        
        
        
        
     #   c(actionButton("a", ans()),actionButton("a", ans()))
        
      }
        #forparameters()
            } )
    
    #output$nameofdam<-renderPrint({
   #input$damlabel1
     # nameofdam<- sapply(1:ans(),function(i) {
    #    input[[paste"damlabel1"]]
      # test<-sapply(1:ans(),funtion(i) {input[[]]})
      
    #}
      
    #)
      
    
    
    
    
    ##### TEST####
    ##############
    #############
    
    output[["riversinput"]]<-renderUI({rivinput2()})
    
    rivinput2<-eventReactive(input$loadbutton1,{
      rivinput()
    })
    rivinput<-function(){
      
      labelsfull<-c("Adult upstream", "Juvenile Downstream","Adult Downstream")
      labelsshort<-c("AU","JD","AD")
      nofpar<-1:3
      k<-NULL
      
      
      
      if (input$river!=1){
       # l<-rep(j,each=3)
        #####OLD TEST
        # for (j in 1:ans()){
        #   paste0("div(class= 'option-header', '",D[j],"'),flowLayout(",
        #          
        #          
        #          paste0("column(12, sliderInput(",
        #                paste0("'",labelsshort[nofpar], ans()),"', '", labelsfull[noofpar], "',min = 0, max=100, value=50, step = 1))",
        #                collapse = ", "),
        #          ")",collapse=", "
        #          )
        #     
        #    
        # }
        
        #######
        for (j in 1:ans()){
         m<- paste0("div(class= 'option-header', h3('",input[[paste0("damlabel",j)]],"')),flowLayout(",
                        paste0("column(12, sliderInput(",
                        paste0("'",labelsshort[nofpar], j),"', '", labelsfull[nofpar], "',min = 0, max=100, value=50, step = 1))",
                        collapse = ", "),
                 "), br(),",collapse=", "
                 
          )
          k<-paste0(k,m)
          
        } 
        output$FAQpassage<-renderPrint({"Text explaining passage?"})
        
        
        theresult<-paste0("div(class='option-group',
               div(class='option-header', tags$h4('PASSAGE')),
                          setSliderColor(rep('black',1000),1:1000),
       chooseSliderSkin('Nice'),",
           k,
          "flowLayout(
         
          
          column(9,
                 numericInput('ayears',tags$h6('Years'),300))
          
        ),
 flowLayout(
        column(9,
          actionButton('runthemodel','RUN'))
)
)
        "
          
        )
        
      } else {
        
        theresult<-'div(class="option-group",
                                     div(class="option-header",fluidRow(column(3,
tags$h4("PASSAGE")),column(3,dropdownButton(tags$h4("text"),tags$h5("Here we will explain what this is about"), circle=F,status="danger", label="?" ,width="300px",tooltip=tooltipOptions(title="Click"))))),
         setSliderColor(rep("black",1000),1:1000),
       chooseSliderSkin("Nice"),
        div(class= "option-header", h3("Milltown")),
        flowLayout(
        column(12,
        sliderInput("MTAU1", tags$h6("Adult Upstream"),min = 0, max=100, value=60, step = 1)),
        column(12,
        sliderInput("MTAD1", tags$h6("Adult Downstream"),min = 0, max=100, value=90, step = 1)),
        column(12,
        sliderInput("MTJD1", tags$h6("Juvenile Downstream"),min = 0, max=100, value=90, step = 1))
        ),
        br(),
        div(class= "option-header", h3("Woodland")),
        flowLayout(
        column(12,
        sliderInput("WLAU1",tags$h6("Adult Upstream"),min = 0, max=100, value=40, step = 1)),
        column(12,
        sliderInput("WLAD1", tags$h6("Adult Downstream"),min = 0, max=100, value=90, step = 1)),
        column(12,
        sliderInput("WLJD1", tags$h6("Juvenile Downstream"),min = 0, max=100, value=90, step = 1))
        ),
br(),        
div(class= "option-header", h3("Grand Falls")),
        flowLayout(
        column(12,
        sliderInput("GFAU1", tags$h6("Adult Upstream"),min = 0, max=100, value=75, step = 1)),
        column(12,
        sliderInput("GFAD1", tags$h6("Adult Downstream"),min = 0, max=100, value=90, step = 1)),
        column(12,
        sliderInput("GFJD1", tags$h6("Juvenile Downstream"),min = 0, max=100, value=90, step = 1))
        ),
br(),
        div(class= "option-header", h3("Spednic")),
        flowLayout(
        column(12,
        sliderInput("SPAU1", tags$h6("Adult Upstream"),min = 0, max=100, value=67, step = 1)),
        column(12,
        sliderInput("SPAD1", tags$h6("Adult Downstream"),min = 0, max=100, value=90, step = 1)),
        column(12,
        sliderInput("SPJD1", tags$h6("Juvenile Downstream"),min = 0, max=100, value=90, step = 1))
        ),
        
        flowLayout(
         
        
        column(9,
        numericInput("ayears",tags$h6("Years"),200))
        
),
        
       
        flowLayout(
        column(4,
        actionButton("runthemodel","RUN",style = "color: rgb(0, 0, 0); font-size: 25px; line-height: 30px; padding: 8px; border-radius: 1px; font-family: Verdana, Geneva, sans-serif; font-weight: 150; text-decoration: none; font-style: normal; font-variant: normal; text-transform: none; border: 2px solid #000000; display: inline-block;}")),
        column(4,
        actionButton("changevalues","Reset Values",style = "color: rgb(0, 0, 0); font-size: 25px; line-height: 30px; padding: 8px; border-radius: 1px; font-family: Verdana, Geneva, sans-serif; font-weight: 150; text-decoration: none; font-style: normal; font-variant: normal; text-transform: none; border: 2px solid #000000; display: inline-block;}"))
)
)
        '
      }
      theresult2<-eval(parse(text=theresult))
      
      return(theresult2)
    } 
    
    observeEvent(input$changevalues, {
      updateSliderInput(session, "MTAU1", value = 60)
      updateSliderInput(session, "MTAD1", value = 90)
      updateSliderInput(session, "MTJD1", value = 90)
      updateSliderInput(session, "WLAU1", value = 40)
      updateSliderInput(session, "WLAD1", value = 90)
      updateSliderInput(session, "WLJD1", value = 90)
      updateSliderInput(session, "GFAU1", value = 75)
      updateSliderInput(session, "GFAD1", value = 90)
      updateSliderInput(session, "GFJD1", value = 90)
      updateSliderInput(session, "SPAU1", value = 60)
      updateSliderInput(session, "SPAD1", value = 90)
      updateSliderInput(session, "SPJD1", value = 90)
    })
    
    ####TEST##############
    ##################
    ###############
      
    output$see2<-renderText({
      if (input$river!=1) {"step 2: choose your parameters"}
    } )
    
     observeEvent(input$loadbutton1,{
       showTab(inputId = "tabs", target = "Comparative model")
     })
    
     observeEvent(input$app,{
       showTab(inputId = "tabs", target = "test101")
     })
     
    output$riverout<-renderUI({ 
      
      
      #if (input$river==1){
        
       # output$stcroix<-renderText({
        #  "If you read this, this chunk of code is working"
        #})
      
      #} else if (input$river==2){
      if (input$river==2){
       radioButtons("test", "Choose number of dams", (1:10))
        
      }
    }) 
    
   
    
    output$Parameters <- renderUI({
     forparameters()
        
    }) 
    
    
    output$StCroix<-renderText({
        "If you read this, this chunk of code is working"
      })
    }
) 