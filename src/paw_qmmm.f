! 
!.......................................................................
MODULE QMMM_MODULE
!***********************************************************************
!**                                                                   **
!**  NAME: QMMM                                                       **
!**                                                                   **
!**  PURPOSE: COUPLES A QUANTUM MECHANICAL (QM) MOLECULE ON AN        **
!**  MOLECULAR MECHANICAL (MM) ENVIRONMENT.                           **
!**                                                                   **
!**  THREE SYSTEMS ARE TREATED:                                       **
!**  1) THE QM-MOLECULE (NOT IN THIS OBJECT)                          **
!**  2) THE MM-SHADOW OF THE QM-MOLECULE                              **
!**  3) THE MM ENVIRONMENT AND ITS EMBEDDED MOLECULE                  **
!**  THE TOTAL ENERGY OF THE COMBINED SYSTEM IS E1+(E3_E2)            **
!**                                                                   **
!**  METHODS:                                                         **
!**    QMMM$INTERFACE                                                 **
!**    QMMM$scaleforce(nat,qforce)                                    **
!**    QMMM$PROPAGATE                                                 **
!**    QMMM$SWITCH                                                    **
!**                                                                   **
!**  USES:                                                            **
!**    CLASSICAL                                                      **
!**                                                                   **
!**  remarks:                                                         **
!**  THE ENERGIES FROM THIS MODULE ARE ACCESSED VIA                   **
!**      QMMM$GETR8('EPOT',VAL)                                       **
!**      QMMM$GETR8('EKIN',VAL)                                       **
!**      QMMM$GETR8('ETHERM',VAL)                                     **
!**  THE ENERGYLIST IS NOT USED IN THIS OBJECT                        **
!**                                                                   **
!***********************************************************************
TYPE LINK_TYPE
  INTEGER(4)  :: QJOINT
  INTEGER(4)  :: MJOINT
  INTEGER(4)  :: SJOINT
  INTEGER(4)  :: QATOM
  INTEGER(4)  :: MATOM
  INTEGER(4)  :: SATOM
  REAL(8)     :: ALPHA
  REAL(8)     :: MCHARGE
END TYPE LINK_TYPE
TYPE MAP_TYPE
  INTEGER(4)  :: QATOM
  INTEGER(4)  :: MATOM
  INTEGER(4)  :: SATOM
END TYPE MAP_TYPE
LOGICAL(4)                  :: TON  =.FALSE. ! ON/OFF SWITCH
LOGICAL(4)                  :: TINI =.FALSE. ! FLAG FOR INITIALIZATION
LOGICAL(4)                  :: TMOVE=.FALSE. ! MOVE ATOMS OR FREEZE MOTION
LOGICAL(4)                  :: TADIABATIC=.FALSE.  !MINIMIZATION IN EACH TIME STEP
REAL(8)                     :: DELTAT=10.D0  ! TIMESTEP
REAL(8)                     :: ANNE =0.D0    ! FRICTION
LOGICAL(4)                  :: TSTOP=.TRUE.  ! SET VELOCITIES TO ZERO
LOGICAL(4)                  :: TRANDOMIZE=.FALSE.  ! RANDOMIZE VELOCITIES
REAL(8)                     :: AMPRE=0.D0    ! K_B*T FOR RANDOMIZATION
INTEGER(4)                  :: NMULTIPLE=1   ! #(MULTIPLE TIME STEPS)
INTEGER(4)                  :: NATM=0        ! #(ATOMS IN THE QM+MM)
INTEGER(4)                  :: NATS=0        ! #(SHADOW ATOMS)
INTEGER(4)                  :: NATQ=0        ! #(QM ATOMS)
INTEGER(4)                  :: NLINK=0       ! #(LINK BONDS)
TYPE(LINK_TYPE),ALLOCATABLE :: LINK(:)       ! DEFINES LINK-BONDS
INTEGER(4)                  :: NMAP=0        ! #(QM-ATOMS EXCEPT DUMMY ATOMS)
TYPE(MAP_TYPE) ,ALLOCATABLE :: MAP(:)        ! REACTION CENTER + DUMMY ATOMS
REAL(8)                     :: EPOT_QMMM=0.D0   ! EPOT OF THE ENVIRONMENT
REAL(8)                     :: EKIN_QMMM=0.D0   ! EKIN OF THE ENVIRONMENT
REAL(8)                     :: ETHERM_QMMM=0.D0 ! EKIN+EPOT OF THE THERMOSTAT
END MODULE QMMM_MODULE      
!     ..................................................................
      SUBROUTINE QMMM_INITIALIZE
!     ******************************************************************
!     ******************************************************************
      USE QMMM_MODULE
      USE PERIODICTABLE_MODULE
      IMPLICIT NONE
      INTEGER(4)               :: IATQJ,IATMJ,IATQ,IATM,ILINK,IATS
      REAL(8)                  :: RS,RJ,RM
      REAL(8)     ,ALLOCATABLE :: MQ(:)
      CHARACTER(5),ALLOCATABLE :: MTYPE(:)
      CHARACTER(5),ALLOCATABLE :: STYPE(:)
      LOGICAL(4)               :: TCHK
!     ******************************************************************
      IF(TINI) RETURN
                        CALL TRACE$PUSH('QMMM_INITIALIZE')
      TINI=.TRUE.
!
!     ==================================================================
!     == COLLECT #(ATOMS)                                             ==
!     ==================================================================
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETI4('NAT',NATM)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$GETI4('NAT',NATS)
      CALL ATOMLIST$NATOM(NATQ)
      IF(NATS.NE.NATQ) THEN
        CALL ERROR$MSG('#(QM ATOMS) NOT EQUAL #(SHADOW ATOMS)')
        CALL ERROR$STOP('QMMM_INITIALIZE')
      END IF
!
!     ==================================================================
!     ==  SET ALPHA AND M-CHARGE                                      ==
!     ==================================================================
      ALLOCATE(MQ(NATM))
      ALLOCATE(MTYPE(NATM))
      ALLOCATE(STYPE(NATS))
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('QEL',NATM,MQ)
      CALL CLASSICAL$GETCHA('TYPE',NATM,MTYPE)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$GETCHA('TYPE',NATS,STYPE)
!
      DO ILINK=1,NLINK
        IATQJ=LINK(ILINK)%QJOINT
        IATMJ=LINK(ILINK)%MJOINT
        IATQ=LINK(ILINK)%QATOM
        IATS=LINK(ILINK)%SATOM
        IATM=LINK(ILINK)%MATOM
        CALL PERIODICTABLE$GET(STYPE(IATS)(1:2),'R(COV)',RS)
        CALL PERIODICTABLE$GET(MTYPE(IATM)(1:2),'R(COV)',RM)
        CALL PERIODICTABLE$GET(MTYPE(IATMJ)(1:2),'R(COV)',RJ)
        LINK(ILINK)%ALPHA=(RS+RJ)/(RM+RJ)
        LINK(ILINK)%MCHARGE=MQ(IATM)
      ENDDO
      DEALLOCATE(STYPE)
      DEALLOCATE(MTYPE)
      DEALLOCATE(MQ)
      CALL THERMOSTAT$SELECT('QM-MM')
      CALL THERMOSTAT$GETL4('ON',TCHK)
      IF(TCHK) THEN
        CALL THERMOSTAT$SCALEGFREE(REAL(NATM-NATS,KIND=8))
      END IF
                         CALL TRACE$POP
      RETURN
      END SUBROUTINE QMMM_INITIALIZE
! 
!     ..................................................................
      SUBROUTINE QMMM$SETI4A(ID,LEN,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      INTEGER(4)  ,INTENT(IN) :: LEN
      INTEGER(4)  ,INTENT(IN) :: VALUE(LEN)
      INTEGER(4)              :: I,IMAP,ILINK
!     *******************************************************************
      IF(ID.EQ.'MAP') THEN
        IF(ALLOCATED(MAP)) DEALLOCATE(MAP)
        NMAP=LEN/3
        IF(LEN.NE.3*NMAP) THEN
          CALL ERROR$MSG('LENGTH INCONSISTENT')
          CALL ERROR$STOP('QMMM$SETI4A')
        END IF
        ALLOCATE(MAP(NMAP))
        I=0
        DO IMAP=1,NMAP
          I=I+1; MAP(IMAP)%QATOM=VALUE(I)
          I=I+1; MAP(IMAP)%MATOM=VALUE(I)
          I=I+1; MAP(IMAP)%SATOM=VALUE(I)
        ENDDO
      ELSE IF(ID.EQ.'LINK') THEN
        IF(ALLOCATED(LINK)) DEALLOCATE(LINK)
        NLINK=LEN/6
        IF(LEN.NE.6*NLINK) THEN
          CALL ERROR$MSG('LENGTH INCONSISTENT')
          CALL ERROR$STOP('QMMM$SETI4A')
        END IF
        ALLOCATE(LINK(NLINK))
        I=0
        DO ILINK=1,NLINK
          I=I+1; LINK(ILINK)%QJOINT=VALUE(I)
          I=I+1; LINK(ILINK)%MJOINT=VALUE(I)
          I=I+1; LINK(ILINK)%SJOINT=VALUE(I)
          I=I+1; LINK(ILINK)%QATOM=VALUE(I)
          I=I+1; LINK(ILINK)%MATOM=VALUE(I)
          I=I+1; LINK(ILINK)%SATOM=VALUE(I)
          LINK(ILINK)%ALPHA=0.D0
          LINK(ILINK)%MCHARGE=0.D0
        ENDDO
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$SETI4A')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$GETI4(ID,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      INTEGER(4)  ,INTENT(OUT) :: VALUE
!     *******************************************************************
      IF(ID.EQ.'NAT:ENV') THEN
        VALUE=NATM-NATS
      ELSE IF(ID.EQ.'NAT:ALL') THEN
        VALUE=NATM
      ELSE IF (ID.EQ.'NAT:SHADOW') THEN 
        VALUE=NATS
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$SETI4')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$SETL4(ID,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      LOGICAL(4)  ,INTENT(IN) :: VALUE
!     *******************************************************************
      IF(ID.EQ.'ON') THEN
        TON=VALUE
      ELSE IF(ID.EQ.'STOP') THEN
        TSTOP=VALUE
      ELSE IF(ID.EQ.'MOVE') THEN
        TMOVE=VALUE
      ELSE IF(ID.EQ.'ADIABATIC') THEN
        TADIABATIC=VALUE
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$SETL4')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$GETL4(ID,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      LOGICAL(4)  ,INTENT(OUT):: VALUE
!     *******************************************************************
      IF(ID.EQ.'ON') THEN
        VALUE=TON
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$GETL4')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$SETI4(ID,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      INTEGER(4)  ,INTENT(IN) :: VALUE
!     *******************************************************************
      IF(ID.EQ.'MULTIPLE') THEN
        NMULTIPLE=VALUE
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$SETL4')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$SETR8(ID,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      REAL(8)     ,INTENT(IN) :: VALUE
!     *******************************************************************
      IF(ID.EQ.'TIMESTEP') THEN
        DELTAT=VALUE
      ELSE IF(ID.EQ.'FRICTION') THEN
        ANNE=VALUE
      ELSE IF(ID.EQ.'RANDOM') THEN
        AMPRE=VALUE
        TRANDOMIZE=.TRUE.
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$SETR8')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$GETR8(ID,VALUE)
!     *******************************************************************
!     *******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      CHARACTER(*),INTENT(IN) :: ID
      REAL(8)     ,INTENT(OUT):: VALUE
!     *******************************************************************
      IF(ID.EQ.'EKIN') THEN
        VALUE=EKIN_QMMM
      ELSE IF(ID.EQ.'EPOT') THEN
        VALUE=EPOT_QMMM
      ELSE IF(ID.EQ.'ETHERM') THEN
        VALUE=ETHERM_QMMM
      ELSE 
        CALL ERROR$MSG('ID NOT RECOGNIZED')
        CALL ERROR$CHVAL('ID',ID)
        CALL ERROR$STOP('QMMM$GETR8')
      END IF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$REPORT(NFIL)
!     *****************************************************************
!     *****************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      INTEGER(4),INTENT(IN)  :: NFIL
      REAL(8)                :: KELVIN
      INTEGER(4)             :: NTASKS,THISTASK
!     *****************************************************************
      IF(.NOT.TON) RETURN
      CALL MPE$QUERY(NTASKS,THISTASK)
                              CALL TRACE$PUSH('QMMM$REPORT')
      IF(THISTASK.EQ.1) THEN
        CALL CONSTANTS('KB',KELVIN)
        CALL REPORT$TITLE(NFIL,'QM-MM COUPLING')
        IF(TSTOP)CALL REPORT$STRING(NFIL,'ZERO INITIAL VELOCITIES OF ENVIRONMENT')
        IF(TADIABATIC)CALL REPORT$STRING(NFIL,'MM ATOMS RELAXED IN EACH TIME STEP')
        CALL REPORT$I4VAL(NFIL,'ENVIRONMENT OVERSAMPLED BY FACTOR',NMULTIPLE,' ')
        IF(.NOT.TMOVE)CALL REPORT$STRING(NFIL,'ENVIRONMENT FROZEN')
        CALL REPORT$R8VAL(NFIL,'FRICTION',ANNE,' ')
        IF(TRANDOMIZE) THEN
          CALL REPORT$R8VAL(NFIL,'INITIAL VELOCITIES RANDOMIZED WITH',AMPRE/KELVIN,'K')
        END IF
        CALL REPORT$I4VAL(NFIL,'NUMBER OF ATOMS INCLUDING ENVIRONMENT',NATM,' ')
        CALL REPORT$I4VAL(NFIL,'NUMBER OF ATOMS IN SHADOW',NATS,' ')
!
!     ==================================================================
!     == REPORT POSITIONS, BONDS FOR THE MM-ENVIRONMENT               ==
!     ==================================================================
        CALL REPORT$STRING(NFIL,'MM-ENVIRONMENT')
      END IF
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$REPORT(NFIL)
                             CALL TRACE$POP
      RETURN
      END

!     ..................................................................
      SUBROUTINE QMMM$INTERFACEOLD(NAT,POS,CHARGE,FORCE,POT,DEPOT)
!     *****************************************************************
!     *****************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      INTEGER(4),INTENT(IN)  :: NAT      
      REAL(8)   ,INTENT(IN)  :: POS(3,NAT)
      REAL(8)   ,INTENT(IN)  :: CHARGE(NAT)
      REAL(8)   ,INTENT(OUT) :: FORCE(3,NAT)
      REAL(8)   ,INTENT(OUT) :: POT(NAT)
      REAL(8)   ,INTENT(OUT) :: DEPOT
      REAL(8)   ,ALLOCATABLE :: MPOS(:,:)
      REAL(8)   ,ALLOCATABLE :: SPOS(:,:)
      REAL(8)   ,ALLOCATABLE :: MCHARGE(:)
      REAL(8)   ,ALLOCATABLE :: SCHARGE(:)
      REAL(8)   ,ALLOCATABLE :: MFORCE(:,:)
      REAL(8)   ,ALLOCATABLE :: SFORCE(:,:)
      REAL(8)   ,ALLOCATABLE :: MPOT(:)
      REAL(8)   ,ALLOCATABLE :: SPOT(:)
      REAL(8)                :: EPOTM,EPOTS
      INTEGER(4)             :: IMAP,ILINK
      INTEGER(4)             :: IATQ,IATM,IATS,IATQJ,IATMJ,IATSJ
      REAL(8)                :: ALPHA
      LOGICAL(4),PARAMETER   :: TPR=.TRUE.
      REAL(8)   ,PARAMETER   :: TOL=5.D-4  !TOLERANCE FOR ADIABATIC MINIMIZATION
      REAL(8)                :: SVAR
      LOGICAL(4)             :: TCHK
      INTEGER(4)             :: NFILO
!     *****************************************************************
      DEPOT=0.D0
      POT(:)=0.D0
      FORCE(:,:)=0.D0
      IF(.NOT.TON) RETURN
                        CALL TRACE$PUSH('QMMM$INTERFACE')
      CALL QMMM_INITIALIZE
                        CALL TIMING$CLOCKON('QM-MM')
      ALLOCATE(MPOS(3,NATM))
      ALLOCATE(MCHARGE(NATM))
      ALLOCATE(MFORCE(3,NATM))
      ALLOCATE(MPOT(NATM))
      ALLOCATE(SPOS(3,NATS))
      ALLOCATE(SCHARGE(NATS))
      ALLOCATE(SFORCE(3,NATS))
      ALLOCATE(SPOT(NATS))
!
!     ==================================================================
!     ==  ENFORCE CONSTRAINTS                                         ==
!     ==================================================================
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('R(0)',3*NATM,MPOS)
      CALL CLASSICAL$GETR8A('QEL',NATM,MCHARGE)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$GETR8A('R(0)',3*NATS,SPOS)
      CALL CLASSICAL$GETR8A('QEL',NATS,SCHARGE)
      DO IMAP=1,NMAP
        IATQ=MAP(IMAP)%QATOM
        IATM=MAP(IMAP)%MATOM
        IATS=MAP(IMAP)%SATOM
        MPOS(:,IATM)=POS(:,IATQ)
        SPOS(:,IATS)=POS(:,IATQ)
        MCHARGE(IATM)=CHARGE(IATQ)
        SCHARGE(IATS)=CHARGE(IATQ)
      ENDDO      
      DO ILINK=1,NLINK
        IATQJ=LINK(ILINK)%QJOINT
        IATMJ=LINK(ILINK)%MJOINT
        IATSJ=LINK(ILINK)%SJOINT
        IATQ =LINK(ILINK)%QATOM
        IATM =LINK(ILINK)%MATOM
        IATS =LINK(ILINK)%SATOM
        ALPHA=LINK(ILINK)%ALPHA
        MPOS(:,IATM)=POS(:,IATQJ)+(POS(:,IATQ)-POS(:,IATQJ))/ALPHA
        SPOS(:,IATS)=POS(:,IATQ)
!       == NOTE THAT THE CHARGE OF THE M ATOM MUST BE RESET!! ========
        MCHARGE(IATM) =LINK(ILINK)%MCHARGE+ALPHA*CHARGE(IATQ)
        MCHARGE(IATMJ)=MCHARGE(IATMJ)+(1.D0-ALPHA)*CHARGE(IATQ)
        SCHARGE(IATS) =CHARGE(IATQ)
      ENDDO
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$SETR8A('R(0)',3*NATM,MPOS)
      CALL CLASSICAL$SETR8A('QEL',NATM,MCHARGE)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$SETR8A('R(0)',3*NATS,SPOS)
      CALL CLASSICAL$SETR8A('QEL',NATS,SCHARGE)
!
!     ==================================================================
!     ==  RELAX STRUCTURE                                             ==
!     ==================================================================
      IF(TADIABATIC) THEN
        CALL CLASSICAL$SELECT('QMMM')
        CALL CLASSICAL$NEIGHBORS
        CALL QMMM_MINIMIZE(TCHK)
      END IF
!
!     ==================================================================
!     ==  CALCULATE FORCES                                            ==
!     ==================================================================
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$NEIGHBORS
      CALL CLASSICAL$ETOT(EPOTM)  
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$NEIGHBORS
      CALL CLASSICAL$ETOT(EPOTS)  
!
!     ==================================================================
!     ==  CALCULATE FORCES                                            ==
!     ==================================================================
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('FORCE',3*NATM,MFORCE)
      CALL CLASSICAL$GETR8A('VEL',NATM,MPOT)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$GETR8A('FORCE',3*NATS,SFORCE)
      CALL CLASSICAL$GETR8A('VEL',NATS,SPOT)
      DO IMAP=1,NMAP
        IATQ=MAP(IMAP)%QATOM
        IATM=MAP(IMAP)%MATOM
        IATS=MAP(IMAP)%SATOM
        FORCE(:,IATQ)=MFORCE(:,IATM)-SFORCE(:,IATS)
        POT(IATQ)=MPOT(IATM)-SPOT(IATS)
      ENDDO        
      DO ILINK=1,NLINK
        IATQJ=LINK(ILINK)%QJOINT
        IATMJ=LINK(ILINK)%MJOINT
        IATSJ=LINK(ILINK)%SJOINT
        IATQ =LINK(ILINK)%QATOM
        IATM =LINK(ILINK)%MATOM
        IATS =LINK(ILINK)%SATOM
        ALPHA=LINK(ILINK)%ALPHA
        FORCE(:,IATQ)=-SFORCE(:,IATS)
        IF(TADIABATIC) THEN
          FORCE(:,IATQ)=FORCE(:,IATQ)+MFORCE(:,IATM)/ALPHA
          FORCE(:,IATQJ)=FORCE(:,IATQJ)+MFORCE(:,IATM)*(1.D0-1.D0/ALPHA)
        END IF
        POT(IATQ)=ALPHA*MPOT(IATM)+(1.D0-ALPHA)*MPOT(IATMJ)-SPOT(IATS)
!
!       == HERE RESET CHARGE ON M ATOM HERE
        MCHARGE(IATM)=LINK(ILINK)%MCHARGE
      ENDDO
      DEPOT=EPOTM-EPOTS
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$SETR8A('QEL',NATM,MCHARGE)
!
      DEALLOCATE(MPOS)
      DEALLOCATE(MCHARGE)
      DEALLOCATE(MFORCE)
      DEALLOCATE(MPOT)
      DEALLOCATE(SPOS)
      DEALLOCATE(SCHARGE)
      DEALLOCATE(SFORCE)
      DEALLOCATE(SPOT)
!
!     ==================================================================
!     ==  PRINTOUT                                                    ==
!     ==================================================================
      IF(TPR) THEN
        WRITE(*,FMT='("QM-MM TOTAL ENERGY",F10.5)')DEPOT
        DO IATQ=1,NAT
          SVAR=DSQRT(DOT_PRODUCT(FORCE(:,IATQ),FORCE(:,IATQ)))
          WRITE(*,FMT='("IAT ",I3,"|F|",F10.5," F ",3F10.5," POT ",F10.5)') &
     &         IATQ,SVAR,FORCE(:,IATQ),POT(IATQ)
        ENDDO
      ENDIF
                        CALL TIMING$CLOCKOFF('QM-MM')
                        CALL TRACE$POP
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$INTERFACE(NAT,POS,CHARGE,FORCE,POT,DEPOT)
!     *****************************************************************
!     *****************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      INTEGER(4),INTENT(IN)  :: NAT      
      REAL(8)   ,INTENT(IN)  :: POS(3,NAT)
      REAL(8)   ,INTENT(IN)  :: CHARGE(NAT)
!REAL(8)   ,INTENT(INOUT)  :: CHARGE(NAT)
!REAL(8)   ,INTENT(INOUT)  :: POS(3,NAT)
!INTEGER(4) :: IX=18
LOGICAL(4):: TFIRST=.TRUE.
REAL(8),SAVE :: POTX(5)
      REAL(8)   ,INTENT(OUT) :: FORCE(3,NAT)
      REAL(8)   ,INTENT(OUT) :: POT(NAT)
      REAL(8)   ,INTENT(OUT) :: DEPOT
      REAL(8)   ,ALLOCATABLE :: MPOS(:,:)
      REAL(8)   ,ALLOCATABLE :: MPOSM(:,:)
      REAL(8)   ,ALLOCATABLE :: SPOS(:,:)
      REAL(8)   ,ALLOCATABLE :: MCHARGE(:)
      REAL(8)   ,ALLOCATABLE :: SCHARGE(:)
      REAL(8)   ,ALLOCATABLE :: MFORCE(:,:)
      REAL(8)   ,ALLOCATABLE :: SFORCE(:,:)
      REAL(8)   ,ALLOCATABLE :: QFORCE(:,:)
      REAL(8)   ,ALLOCATABLE :: MPOT(:)
      REAL(8)   ,ALLOCATABLE :: SPOT(:)
      REAL(8)   ,ALLOCATABLE :: QPOT(:)
      REAL(8)                :: EPOTM,EPOTS
      REAL(8)                :: EKINMM
      INTEGER(4)             :: IMAP,ILINK
      INTEGER(4)             :: IATQ,IATM,IATS,IATQJ,IATMJ,IATSJ
      REAL(8)                :: ALPHA
      LOGICAL(4),PARAMETER   :: TPR=.TRUE.
      REAL(8)                :: SVAR
      LOGICAL(4)             :: TCHK
      INTEGER(4)             :: NFILO
      INTEGER(4)             :: IMULTIPLE
      LOGICAL(4)             :: TTHERMOSTAT
      REAL(8)                :: ENOSE
!     *****************************************************************
      DEPOT=0.D0
      POT(:)=0.D0
      FORCE(:,:)=0.D0
      IF(.NOT.TON) RETURN
                        CALL TRACE$PUSH('QMMM$INTERFACE')
      CALL QMMM_INITIALIZE
                        CALL TIMING$CLOCKON('QM-MM')
      ALLOCATE(MPOS(3,NATM))
      ALLOCATE(MPOSM(3,NATM))
      ALLOCATE(MCHARGE(NATM))
      ALLOCATE(MFORCE(3,NATM))
      ALLOCATE(MPOT(NATM))
      ALLOCATE(SPOS(3,NATS))
      ALLOCATE(SCHARGE(NATS))
      ALLOCATE(SFORCE(3,NATS))
      ALLOCATE(SPOT(NATS))
      ALLOCATE(QPOT(NAT))
      ALLOCATE(QFORCE(3,NAT))
!
!     ==================================================================
!     ==  APPLY CONSTRAINTS                                           ==
!     ==  AND SET VELOCITIES FOR REACTION CENTER AND LINK ATOMS       ==
!     ==  IN THE MM-PART TO ZERO                                      ==
!     ==================================================================
!POS(1,IX)=-1.D-3
! 1000 CONTINUE
!POS(1,IX)=POS(1,IX)+1.D-3
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('R(0)',3*NATM,MPOS)
      CALL CLASSICAL$GETR8A('R(-)',3*NATM,MPOSM)
      CALL CLASSICAL$GETR8A('QEL',NATM,MCHARGE)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$GETR8A('R(0)',3*NATS,SPOS)
      CALL CLASSICAL$GETR8A('QEL',NATS,SCHARGE)
      DO IMAP=1,NMAP
        IATQ=MAP(IMAP)%QATOM
        IATM=MAP(IMAP)%MATOM
        IATS=MAP(IMAP)%SATOM
        MPOS(:,IATM)=POS(:,IATQ)
        MPOSM(:,IATM)=MPOS(:,IATM)   !SET VELOCITY TO ZERO FOR CENTRAL CLUSTER
        SPOS(:,IATS)=POS(:,IATQ)
        MCHARGE(IATM)=CHARGE(IATQ)
        SCHARGE(IATS)=CHARGE(IATQ)
      ENDDO      
      DO ILINK=1,NLINK
        IATQJ=LINK(ILINK)%QJOINT
        IATMJ=LINK(ILINK)%MJOINT
        IATSJ=LINK(ILINK)%SJOINT
        IATQ =LINK(ILINK)%QATOM
        IATM =LINK(ILINK)%MATOM
        IATS =LINK(ILINK)%SATOM
        ALPHA=LINK(ILINK)%ALPHA
        MPOS(:,IATM)=POS(:,IATQJ)+(POS(:,IATQ)-POS(:,IATQJ))/ALPHA
        MPOSM(:,IATM)=MPOS(:,IATM)   !SET VELOCITIES TO ZERO
        SPOS(:,IATS)=POS(:,IATQ)
!       == NOTE THAT THE CHARGE OF THE M ATOM MUST BE RESET!! ========
        MCHARGE(IATM) =LINK(ILINK)%MCHARGE+ALPHA*CHARGE(IATQ)
        MCHARGE(IATMJ)=MCHARGE(IATMJ)+(1.D0-ALPHA)*CHARGE(IATQ)
        SCHARGE(IATS) =CHARGE(IATQ)
      ENDDO
PRINT*,'DR ',MPOS-MPOSM
PRINT*,'MQ ',MCHARGE
PRINT*,'SQ ',SCHARGE
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$SETR8A('R(0)',3*NATM,MPOS)
      CALL CLASSICAL$SETR8A('R(-)',3*NATM,MPOSM)
      CALL CLASSICAL$SETR8A('QEL',NATM,MCHARGE)
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$SETR8A('R(0)',3*NATS,SPOS)
      CALL CLASSICAL$SETR8A('QEL',NATS,SCHARGE)
!
!     ==================================================================
!     ==  TOTAL ENERGY AND FORCES OF THE SHADOW                       ==
!     ==================================================================
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$NEIGHBORS
      CALL CLASSICAL$ETOT(EPOTS)  
      CALL CLASSICAL$GETR8A('FORCE',3*NATS,SFORCE)
      CALL CLASSICAL$GETR8A('VEL',NATS,SPOT)
!
!     ==================================================================
!     ==  SET VELOCITIES TO ZERO IF REQUESTED                         ==
!     ==================================================================
      IF(TSTOP) THEN
        CALL CLASSICAL$SELECT('QMMM')
        CALL CLASSICAL$GETR8A('R(0)',3*NATM,MPOS)
        CALL CLASSICAL$SETR8A('R(-)',3*NATM,MPOS)
        CALL CLASSICAL$SELECT('SHADOW')
        CALL CLASSICAL$GETR8A('R(0)',3*NATS,SPOS)
        CALL CLASSICAL$SETR8A('R(-)',3*NATS,SPOS)
        TSTOP=.FALSE.
      END IF
!
!     ==================================================================
!     ==  RANDOMIZE INITIAL VELOCITIES                                ==
!     ==================================================================
      IF(TRANDOMIZE) THEN
        CALL QMMM_RANDOMIZEVELOCITY
        TRANDOMIZE=.FALSE.
      END IF
!
!     ==================================================================
!     ==  SELECT THERMOSTAT                                           ==
!     ==================================================================
      CALL THERMOSTAT$SELECT('QM-MM')
      CALL THERMOSTAT$GETL4('ON',TTHERMOSTAT)
!
!     ==================================================================
!     ==  MULTIPLE TIMESTEP LOOP                                      ==
!     ==================================================================
      EPOT_QMMM=0.D0
      EKIN_QMMM=0.D0
      ETHERM_QMMM=0.D0
      FORCE(:,:)=0.D0
      POT(:)=0.D0
      CALL CLASSICAL$SELECT('QMMM')
      DO IMULTIPLE=1,NMULTIPLE
!
!       ==================================================================
!       ==  CALCULATE FORCES                                            ==
!       ==================================================================
                        CALL TIMING$CLOCKON('QM-MM:NEIGHBORS')
        CALL CLASSICAL$NEIGHBORS
                        CALL TIMING$CLOCKOFF('QM-MM:NEIGHBORS')
        IF(TADIABATIC) THEN
          CALL QMMM_MINIMIZE(TCHK)
        END IF
                        CALL TIMING$CLOCKON('QM-MM:ETOT')
        CALL CLASSICAL$ETOT(EPOTM)  
        EPOT_QMMM=EPOT_QMMM+EPOTM-EPOTS
                        CALL TIMING$CLOCKOFF('QM-MM:ETOT')
!
!       ==================================================================
!       ==  CALCULATE FORCES ON THE QUANTUM PART                        ==
!       ==================================================================
        CALL CLASSICAL$GETR8A('FORCE',3*NATM,MFORCE)
        CALL CLASSICAL$GETR8A('VEL',NATM,MPOT)
        DO IMAP=1,NMAP
          IATQ=MAP(IMAP)%QATOM
          IATM=MAP(IMAP)%MATOM
          IATS=MAP(IMAP)%SATOM
          QFORCE(:,IATQ)=MFORCE(:,IATM)-SFORCE(:,IATS)
          QPOT(IATQ)    =MPOT(IATM)-SPOT(IATS)
        ENDDO        
        DO ILINK=1,NLINK
          IATQJ=LINK(ILINK)%QJOINT
          IATMJ=LINK(ILINK)%MJOINT
          IATSJ=LINK(ILINK)%SJOINT
          IATQ =LINK(ILINK)%QATOM
          IATM =LINK(ILINK)%MATOM
          IATS =LINK(ILINK)%SATOM
          ALPHA=LINK(ILINK)%ALPHA
          QFORCE(:,IATQ) =MFORCE(:,IATM)/ALPHA-SFORCE(:,IATS)
          QFORCE(:,IATQJ)=QFORCE(:,IATQJ)+MFORCE(:,IATM)*(1.D0-1.D0/ALPHA)
          QPOT(IATQ)=ALPHA*MPOT(IATM)+(1.D0-ALPHA)*MPOT(IATMJ)-SPOT(IATS)
        ENDDO
        POT(:)=POT(:)+QPOT(:)
        FORCE(:,:)=FORCE(:,:)+QFORCE(:,:)
!
!       ==================================================================
!       ==  DO NOT PROPAGATE ADIABATIC SOLUTION                         ==
!       ==================================================================
!PRINT*,'=====',POS(1,IX),EPOTM-EPOTS,FORCE(1,IX)
!IF(POS(1,IX).GT.1.D-2) STOP
!GOTO 1000
        IF(TADIABATIC.OR.(.NOT.TMOVE)) THEN
          CALL CLASSICAL$GETR8A('R(0)',3*NATM,MPOS)
          CALL CLASSICAL$SETR8A('R(+)',3*NATM,MPOS)
          EXIT
        END IF
!
!       ==================================================================
!       ==  PROPAGATE SMALL TIME STEPS                                  ==
!       ==================================================================
        IF(TTHERMOSTAT) THEN
          CALL THERMOSTAT$GETR8('COOLING',ANNE)
        END IF
        CALL CLASSICAL$PROPAGATE(DELTAT,ANNE)
!
!       ==================================================================
!       ==  ENFORCE CONSTRAINTS                                         ==
!       ==================================================================
        CALL CLASSICAL$GETR8A('R(+)',3*NATM,MPOS)
        DO IMAP=1,NMAP
          IATQ=MAP(IMAP)%QATOM
          IATM=MAP(IMAP)%MATOM
          MPOS(:,IATM)=POS(:,IATQ)
        ENDDO      
        DO ILINK=1,NLINK
          IATQJ=LINK(ILINK)%QJOINT
          IATQ =LINK(ILINK)%QATOM
          IATM =LINK(ILINK)%MATOM
          ALPHA=LINK(ILINK)%ALPHA
          MPOS(:,IATM)=POS(:,IATQJ)+(POS(:,IATQ)-POS(:,IATQJ))/ALPHA
        ENDDO
        CALL CLASSICAL$SETR8A('R(+)',3*NATM,MPOS)
!
!       ==================================================================
!       ==  OBTAIN KINETIC ENERGY (MM-ATOMS EXCEPT LINK ATOMS AND       ==
!       ==                        ATOMS OF THE REACTION CENTER)
!       ==================================================================
        CALL CLASSICAL$EKIN(DELTAT,EKINMM)
        EKIN_QMMM=EKIN_QMMM+EKINMM
!
!       ==================================================================
!       ==  PROPAGATE THERMOSTAT                                        ==
!       ==================================================================
        CALL THERMOSTAT$SETR8('EKIN(SYSTEM)',EKINMM)
        CALL THERMOSTAT$PROPAGATE
        CALL THERMOSTAT$GETR8('ENERGY',ENOSE)
        ETHERM_QMMM=ETHERM_QMMM+ENOSE   ! CONTAINS KINETIC AND POTENTIAL ENERGY
!
!       ==================================================================
!       ==  SWITCH EXCEPT THE LAST                                      ==
!       ==================================================================
        IF(IMULTIPLE.LT.NMULTIPLE) THEN
          CALL CLASSICAL$SWITCH
          CALL THERMOSTAT$SWITCH
        END IF
PRINT*,'ENERGIES ',EPOTM-EPOTS,EKINMM,ENOSE,EPOTM-EPOTS+EKINMM+ENOSE
      ENDDO
      IF(.NOT.TADIABATIC) THEN
        SVAR=1.D0/DBLE(NMULTIPLE)
        EKIN_QMMM  =SVAR*EKIN_QMMM
        EPOT_QMMM  =SVAR*EPOT_QMMM
        ETHERM_QMMM=SVAR*ETHERM_QMMM
        FORCE(:,:) =SVAR*FORCE(:,:)
        POT(:)     =SVAR*POT(:)
      END IF
      DEPOT      =EPOT_QMMM
PRINT*,'EKIN_QMMM',EKIN_QMMM
!PRINT*,'WARNING FROM QMMM$INTERFACE: DEPOT SET TO ZERO'
!DEPOT=0.D0
!IF(TFIRST) THEN
!  POTX=POT
!  TFIRST=.FALSE.
!ELSE
!  POT=POTX
!END IF
!
!     ==================================================================
!     ==  RESET  LINK ATOM POSITIONS FOR T=-T                         ==
!     ==================================================================
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('R(-)',3*NATM,MPOS)
      CALL CLASSICAL$GETR8A('QEL',NATM,MCHARGE)
      DO ILINK=1,NLINK
        IATM =LINK(ILINK)%MATOM
        MCHARGE(IATM)=LINK(ILINK)%MCHARGE
      ENDDO
      CALL CLASSICAL$SETR8A('R(-)',3*NATM,MPOS)
      CALL CLASSICAL$SETR8A('QEL',NATM,MCHARGE)
!
!     ==================================================================
!     ==  PRINTOUT                                                    ==
!     ==================================================================
      DEALLOCATE(MPOS)
      DEALLOCATE(MCHARGE)
      DEALLOCATE(MFORCE)
      DEALLOCATE(MPOT)
      DEALLOCATE(SPOS)
      DEALLOCATE(SCHARGE)
      DEALLOCATE(SFORCE)
      DEALLOCATE(SPOT)
      DEALLOCATE(QPOT)
      DEALLOCATE(QFORCE)
!
!     ==================================================================
!     ==  PRINTOUT                                                    ==
!     ==================================================================
      IF(TPR) THEN
        WRITE(*,FMT='("QM-MM TOTAL ENERGY",F10.5)')DEPOT
        DO IATQ=1,NAT
          WRITE(*,FMT='("IAT ",I3,"|R|",F10.5," R ",3F10.5," CHA ",F10.5)') &
     &         IATQ,0.D0,POS(:,IATQ),CHARGE(IATQ)
          SVAR=DSQRT(DOT_PRODUCT(FORCE(:,IATQ),FORCE(:,IATQ)))
          WRITE(*,FMT='("IAT ",I3,"|F|",F10.5," F ",3F10.5," POT ",F10.5)') &
     &         IATQ,SVAR,FORCE(:,IATQ),POT(IATQ)
        ENDDO
      ENDIF
                        CALL TIMING$CLOCKOFF('QM-MM')
                        CALL TRACE$POP
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM$SCALEFORCE(NAT,QFORCE)
!     ******************************************************************
!     **                                                              **
!     **  RESCALES FORCES ACTING ON THE QM SYSTEM ACCORDING TO THE    **
!     **  EFFECTIVE MASSES. THE EFFECTIVE MASSES RESULT FROM          **
!     **  THE DIFFERENT POSITIONS AND MASSES OF THE MM LINK-ATOMS     **
!     **  AS COMPARED TO THE QM DUMMY ATOMS                           **
!     **                                                              **
!     ******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      INTEGER(4),INTENT(IN)   :: NAT
      REAL(8)   ,INTENT(INOUT):: QFORCE(3,NAT)
      INTEGER(4)              :: ILINK
      INTEGER(4)              :: IATQJ,IATQ,IATM
      REAL(8)                 :: ALPHA
      REAL(8)                 :: MFORCE(3,NATM)
      REAL(8)                 :: QMASS(NATQ)
      REAL(8)                 :: MMASS(NATM)
!     ******************************************************************
      IF (.NOT. TON) RETURN
      IF(NATQ.NE.NAT) THEN
        CALL ERROR$MSG('#(QM ATOMS NOT CONSISTENT')
        CALL ERROR$STOP('QMMM$SCALEFORCE')
      END IF
!
      CALL ATOMLIST$GETR8A('MASS',0,NATQ,QMASS)
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('MASS',NATM,MMASS)
!
!     ==================================================================
!     == MAP FORCES ON MM-ATOMS                                       ==
!     ==================================================================
      DO ILINK=1,NLINK
        IATQJ=LINK(ILINK)%QJOINT
        IATQ =LINK(ILINK)%QATOM
        IATM =LINK(ILINK)%MATOM
        ALPHA=LINK(ILINK)%ALPHA
        QFORCE(:,IATQJ)=QFORCE(:,IATQJ) +(1.D0-ALPHA)*QFORCE(:,IATQ)
        QFORCE(:,IATQ) =                       ALPHA *QFORCE(:,IATQ)
      ENDDO
      DO ILINK=1,NLINK
        IATQJ=LINK(ILINK)%QJOINT
        IATQ =LINK(ILINK)%QATOM
        IATM =LINK(ILINK)%MATOM
        ALPHA=LINK(ILINK)%ALPHA
        QFORCE(:,IATQ) =ALPHA*QMASS(IATQ)/MMASS(IATM) *QFORCE(:,IATQ) &
     &          +(1.D0-ALPHA)*QMASS(IATQ)/QMASS(IATQJ)*QFORCE(:,IATQJ)
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE QMMM$DEKIN(DELT,EKIN)
!     ******************************************************************
!     **                                                              **
!     **  CALCULATE KINETIC ENERGY OF THE LINK ATOMS                  **
!     **                                                              **
!     **  THE KINETIC ENERGY OF THE ENVIRONMENT ATOMS, EXCLUDING      **
!     **  ANY LINK ATOMS, ARE CALCULATED IN $INTERFACE                **
!     **                                                              **
!     ******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      REAL(8)  ,INTENT(IN)  :: DELT  ! TIME STEP OF THE QM SYSTEM
      REAL(8)  ,INTENT(OUT) :: EKIN  ! KINETIC ENERGY CORRECTION
      REAL(8)               :: SVAR1,SVAR2
      REAL(8)               :: QRM(3,NATQ)
      REAL(8)               :: QRP(3,NATQ)
      REAL(8)               :: QMASS(NATQ)
      REAL(8)               :: MRP(3)
      REAL(8)               :: MRM(3)
      REAL(8)               :: MMASS(NATM)
      INTEGER(4)            :: ILINK,I
      INTEGER(4)            :: IATM,IATQ,IATQJ
      REAL(8)               :: ALPHA
!     *****************************************************************
      EKIN=0.D0
      IF (.NOT. TON) RETURN
      IF(TADIABATIC) RETURN
!
      CALL ATOMLIST$GETR8A('R(+)',0,3*NATQ,QRP)
      CALL ATOMLIST$GETR8A('R(-)',0,3*NATQ,QRM)
      CALL ATOMLIST$GETR8A('MASS',0,NATQ,QMASS)
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('MASS',NATM,MMASS)
      DO ILINK=1,NLINK
        IATQ =LINK(ILINK)%QATOM
        IATQJ=LINK(ILINK)%QJOINT
        IATM =LINK(ILINK)%MATOM
        ALPHA=LINK(ILINK)%ALPHA
        MRP(:)=QRP(:,IATQJ)+(QRP(:,IATQ)-QRP(:,IATQJ))/ALPHA
        MRM(:)=QRM(:,IATQJ)+(QRM(:,IATQ)-QRM(:,IATQJ))/ALPHA
        SVAR1=0.D0
        SVAR2=0.D0
        DO I=1,3
          SVAR1=SVAR1+(MRP(I)-MRM(I))**2
          SVAR2=SVAR2+(QRP(I,IATQ)-QRM(I,IATQ))**2
        ENDDO
        SVAR1=SVAR1+0.5D0*MMASS(IATM)*SVAR1/(2.D0*DELT)**2
        SVAR2=SVAR2+0.5D0*QMASS(IATQ)*SVAR2/(2.D0*DELT)**2
        EKIN=EKIN+SVAR1-SVAR2
      ENDDO
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE QMMM$SWITCH
!     ******************************************************************
!     **                                                              **
!     **  R(0)->R(-);   R(+)->R(0)                                    **
!     **                                                              **
!     ******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
!     *****************************************************************
      IF(.NOT.TON) RETURN
      EKIN_QMMM=0.D0
      EPOT_QMMM=0.D0
      CALL CLASSICAL$SELECT('SHADOW')
      CALL CLASSICAL$SWITCH
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$SWITCH
      RETURN
      END
!
!     ..................................................................
      SUBROUTINE QMMM_RANDOMIZEVELOCITY
!     ******************************************************************
!     **                                                              **
!     **  RANDOMIZE VELOCITY ACCORDING TO A GIVEN TEMPERATURE         **
!     **                                                              **
!     **    TEMP     K_B*T WHERE THE T IS THE TEMPERATURE OF THE      **
!     **             HEATBATH                                         **
!     **    THE TARGET KINETIC ENERGY IS 1.5*(NATM-NATS)*TEMP         **
!     **                                                              **
!     ******************************************************************
      USE QMMM_MODULE,ONLY  : DELTAT,AMPRE,NATM,NATS &
     &                       ,NMAP,MAP,NLINK,LINK
      IMPLICIT NONE
      LOGICAL(4),PARAMETER  :: TPR=.TRUE.
      REAL(8)               :: RM(3,NATM)
      REAL(8)               :: RMOLD(3,NATM)
      REAL(8)               :: MASS(NATM)
      INTEGER(4)            :: IAT,I,K,IMAP,ILINK
      REAL(8)               :: SVAR,RAN,SUM
      REAL(8)               :: KELVIN
      INTEGER(4)            :: NFILO
!     ******************************************************************
      CALL CLASSICAL$SELECT('QMMM')
      CALL CLASSICAL$GETR8A('R(-)',3*NATM,RM)
      RMOLD(:,:)=RM(:,:)
      CALL CLASSICAL$GETR8A('MASS',NATM,MASS)
!
!     ==================================================================
!     ==  CHANGE VELOCITIES                                           ==
!     ==================================================================
      DO IAT=1,NATM
        SVAR=DSQRT(AMPRE/MASS(IAT))*DELTAT
        DO I=1,3
          CALL GAUSS_RANDOM_NUMBER(RAN)
          RM(I,IAT) = RM(I,IAT) + SVAR*RAN
        ENDDO
      ENDDO
!
!     ==================================================================
!     ==  LEAVE THE VELOCITIES OF THE REACTION CENTER UNCHANGED       ==
!     ==================================================================
      DO IMAP=1,NMAP
        IAT=MAP(IMAP)%MATOM
        RM(:,IAT)=RMOLD(:,IAT)
      ENDDO
      DO ILINK=1,NLINK
        IAT=LINK(ILINK)%MATOM
        RM(:,IAT)=RMOLD(:,IAT)
      ENDDO
!
!     ==================================================================
!     ==  HAND THE MODIFIED R(-) BACK                                 ==
!     ==================================================================
      CALL CLASSICAL$SETR8A('R(-)',3*NATM,RM)
!
!     ==================================================================
!     ==  PRINTOUT FOR TESTS                                          ==
!     ==================================================================
      IF(TPR) THEN
        SUM=0.D0
        DO IAT=1,NATM
          DO I=1,3
            SUM=SUM+0.5D0*MASS(IAT)*((RM(I,IAT)-RMOLD(I,IAT))/DELTAT)**2
          ENDDO
        ENDDO
        CALL CONSTANTS('KB',KELVIN)
        SUM=SUM/(0.5D0*DBLE(NATM-NATS)*KELVIN)
        CALL FILEHANDLER$UNIT('PROT',NFILO)
        WRITE(NFILO,*)'QMMM-RANDOMIZED: T=',SUM,' KELVIN'
      ENDIF
      RETURN
      END
! 
!     ..................................................................
      SUBROUTINE QMMM_MINIMIZE(TCONV)
!     ******************************************************************
!     **                                                              **
!     **  OPTIMISES ENVIRONMENT ATOMS, EXCLUDING ATOMS OF THE REACTION**
!     **  CENTER AND LINK ATOMS, USING A CONJUGATE GRADIENT MINIMIZER **
!     **                                                              **
!     ******************************************************************
      USE QMMM_MODULE
      IMPLICIT NONE
      LOGICAL(4),INTENT(OUT):: TCONV
      LOGICAL(4),PARAMETER  :: TPR=.FALSE.
      INTEGER(4)            :: NITER=1000
      REAL(8)   ,PARAMETER  :: TOL=1.D-4
      REAL(8)   ,PARAMETER  :: DELT=10.D0
      REAL(8)   ,PARAMETER  :: EKINMAX=0.5D0
      REAL(8)               :: R0(3,NATM)
      REAL(8)               :: RP(3,NATM)
      REAL(8)               :: FORCE(3,NATM)
      REAL(8)               :: FORCE1(3*NATM)
      REAL(8)               :: FORCE2(3*NATM)
      REAL(8)               :: R1(3*NATM)
      REAL(8)               :: R2(3*NATM)
      INTEGER(4)            :: ITER,IMAP,ILINK
      INTEGER(4)            :: IATM,IATMJ
      REAL(8)               :: EPOTP,EPOT,EKIN,ECON,FMAX
      REAL(8)               :: ANNELOC
      REAL(8)               :: ALPHA,SVAR,VEC(3)
      INTEGER(4)            :: NFILO,I1,I2,INNER
!     ******************************************************************
      CALL CLASSICAL$SELECT('QMMM')
!     ==================================================================
!     ==  ITERATE                                                     ==
!     ==================================================================
      NITER=NATM
      EPOTP=1.D+8
      ALPHA=1.D-4
      DO ITER=1,NITER
        IF(MOD(ITER-1,100).EQ.0)CALL CLASSICAL$NEIGHBORS
!       ================================================================
!       ==  PROPAGATE                                                 ==
!       ================================================================
        CALL CLASSICAL$GETR8A('R(0)',3*NATM,R1)
        CALL CLASSICAL$ETOT(EPOT)
        CALL CLASSICAL$GETR8A('FORCE',3*NATM,FORCE1)
        DO IMAP=1,NMAP
          IATM=MAP(IMAP)%MATOM
          I1=3*(IATM-1)+1
          I2=I1+2
          FORCE1(I1:I2)=0.D0
        ENDDO
        DO ILINK=1,NLINK
          IATM=LINK(ILINK)%MATOM
          I1=3*(IATM-1)+1
          I2=I1+2
          FORCE1(I1:I2)=0.D0
        ENDDO
!
!       ================================================================
!       ==  PERFORM CG LINE SEARCH                                    ==
!       ================================================================
        DO INNER=1,3
          R2(:)=R1(:)+ALPHA*FORCE1(:)
          CALL CLASSICAL$SETR8A('R(0)',3*NATM,R2)
          CALL CLASSICAL$ETOT(EPOT)
          CALL CLASSICAL$GETR8A('FORCE',3*NATM,FORCE2)
          DO IMAP=1,NMAP
            IATM=MAP(IMAP)%MATOM
            I1=3*(IATM-1)+1
            I2=I1+2
            FORCE2(I1:I2)=0.D0
          ENDDO
          DO ILINK=1,NLINK
            IATM=LINK(ILINK)%MATOM
            I1=3*(IATM-1)+1
            I2=I1+2
            FORCE2(I1:I2)=0.D0
          ENDDO
          ALPHA=-DOT_PRODUCT(FORCE1,FORCE1) &
      &         /DOT_PRODUCT(FORCE1,FORCE2-FORCE1)*ALPHA
          IF(ALPHA.LT.0.D0) ALPHA=1.D-3
          PRINT*,'INNER ',INNER,ALPHA,DOT_PRODUCT(FORCE1,FORCE2)
        ENDDO
        R2(:)=R1(:)+ALPHA*FORCE1(:)
!
!       ================================================================
!       ==  PRINT                                                     ==
!       ================================================================
        FMAX=SQRT(DOT_PRODUCT(FORCE1,FORCE1))
        IF(TPR) THEN
          CALL FILEHANDLER$UNIT('PROT',NFILO)
          WRITE(NFILO,FMT='("I",I10,"EPOT",E12.5," ALPHA",E15.7' &
     &         //',"FMAX",E12.5)')ITER,EPOT,ALPHA,FMAX
        END IF
        TCONV=(FMAX.LT.TOL)
        IF(TCONV) EXIT
        CALL CLASSICAL$SETR8A('R(0)',3*NATM,R2)
      ENDDO
      PRINT*,'QMMM$MINIMIZE FINISHED AFTER ',ITER,' ITERATIONS'
CALL CLASSICAL$GETR8A('R(0)',3*NATM,R0)
CALL CLASSICAL$GETR8A('FORCE',3*NATM,FORCE)
DO IMAP=1,NMAP
  IATM=MAP(IMAP)%MATOM
  FORCE(:,IATM)=0.D0
ENDDO
DO ILINK=1,NLINK
  IATM=LINK(ILINK)%MATOM
  FORCE(:,IATM)=0.D0
ENDDO
PRINT*,'FORCE FROM QMMM_MINIMIZE'
DO IATM=1,NATM
WRITE(*,FMT='(I5,6F10.5)')IATM,R0(:,IATM),FORCE(:,IATM)
ENDDO
      RETURN
      END   
!
!     ................................................................
      SUBROUTINE QMMM$WRITE(NFIL,NFILO,TCHK)
!     *****************************************************************
!     **                                                             **
!     **                                                             **
!     *****************************************************************
      USE QMMM_MODULE
      USE RESTART_INTERFACE
      IMPLICIT NONE
      INTEGER(4)            ,INTENT(IN) :: NFIL
      INTEGER(4)            ,INTENT(IN) :: NFILO
      LOGICAL(4)           ,INTENT(OUT):: TCHK
      TYPE (SEPARATOR_TYPE),PARAMETER  :: MYSEPARATOR &
                 =SEPARATOR_TYPE(8,'QM-MM','NONE','AUG1996','NONE')
      TYPE (SEPARATOR_TYPE)            :: SEPARATOR
      INTEGER(4)                        :: NAT
      REAL(8)               ,ALLOCATABLE:: R0(:,:)
      REAL(8)               ,ALLOCATABLE:: RM(:,:)
      REAL(8)               ,ALLOCATABLE:: QEL(:)
      INTEGER(4)                        :: NTASKS,ITASK
!     ******************************************************************
      IF(.NOT.TON) RETURN
      CALL WRITESEPARATOR(MYSEPARATOR,NFIL,NFILO,TCHK)
!
!     == WRITE SHADOW ======
      CALL MPE$QUERY(NTASKS,ITASK)
      CALL CLASSICAL$SELECT('SHADOW')
      IF(ITASK.EQ.1) THEN
        CALL CLASSICAL$GETI4('NAT',NAT)
        ALLOCATE(R0(3,NAT))
        ALLOCATE(RM(3,NAT))
        ALLOCATE(QEL(NAT))
        CALL CLASSICAL$GETR8A('R(0)',3*NAT,R0)
        CALL CLASSICAL$GETR8A('R(-)',3*NAT,RM)
        CALL CLASSICAL$GETR8A('QEL',NAT,QEL)
!
        WRITE(NFIL)NAT
        WRITE(NFIL)R0(:,:)
        WRITE(NFIL)RM(:,:)
        WRITE(NFIL)QEL(:)
!
        DEALLOCATE(R0)
        DEALLOCATE(RM)
        DEALLOCATE(QEL)
      END IF
!
!     == WRITE QMMM ======
      CALL CLASSICAL$SELECT('QMMM')
      IF(ITASK.EQ.1) THEN
        CALL CLASSICAL$GETI4('NAT',NAT)
        ALLOCATE(R0(3,NAT))
        ALLOCATE(RM(3,NAT))
        ALLOCATE(QEL(NAT))
        CALL CLASSICAL$GETR8A('R(0)',3*NAT,R0)
        CALL CLASSICAL$GETR8A('R(-)',3*NAT,RM)
        CALL CLASSICAL$GETR8A('QEL',NAT,QEL)
        WRITE(NFIL)NAT
        WRITE(NFIL)R0(:,:)
        WRITE(NFIL)RM(:,:)
        WRITE(NFIL)QEL(:)
        DEALLOCATE(R0)
        DEALLOCATE(RM)
        DEALLOCATE(QEL)
      END IF
      RETURN
      END
!
!     ................................................................
      SUBROUTINE QMMM$READ(NFIL,NFILO,TCHK)
!     *****************************************************************
!     **                                                             **
!     **                                                             **
!     *****************************************************************
      USE QMMM_MODULE
      USE RESTART_INTERFACE
      USE MPE_MODULE
      IMPLICIT NONE
      INTEGER(4)           ,INTENT(IN) :: NFIL
      INTEGER(4)           ,INTENT(IN) :: NFILO
      LOGICAL(4)           ,INTENT(OUT):: TCHK
      TYPE (SEPARATOR_TYPE),PARAMETER  :: MYSEPARATOR &
                 =SEPARATOR_TYPE(8,'QM-MM','NONE','AUG1996','NONE')
      TYPE (SEPARATOR_TYPE)            :: SEPARATOR
      INTEGER(4)                       :: NTASKS,ITASK
      INTEGER(4)                       :: NAT
      INTEGER(4)                       :: I
      REAL(8)              ,ALLOCATABLE:: R0(:,:)
      REAL(8)              ,ALLOCATABLE:: RM(:,:)
      REAL(8)              ,ALLOCATABLE:: QEL(:)
!     ******************************************************************
      TCHK=TON
      SEPARATOR=MYSEPARATOR
      CALL READSEPARATOR(SEPARATOR,NFIL,NFILO,TCHK)
      IF(.NOT.TCHK) RETURN

      CALL MPE$QUERY(NTASKS,ITASK)
      IF(SEPARATOR%VERSION.NE.MYSEPARATOR%VERSION) THEN
        CALL ERROR$MSG('VERSION NOT CONSISTENT')
        CALL ERROR$STOP('QMMM$READ')
      END IF
      CALL QMMM_INITIALIZE
!
!     == READ SHADOW ======
      CALL CLASSICAL$SELECT('SHADOW')
      ALLOCATE(R0(3,NATS))
      ALLOCATE(RM(3,NATS))
      ALLOCATE(QEL(NATS))
      IF(ITASK.EQ.1) THEN
        READ(NFIL)NAT
        IF(NAT.NE.NATS) THEN
          CALL ERROR$MSG('#(SHADOW ATOMS NOT CONSISTENT')
          CALL ERROR$I4VAL('NATS READ',NAT)
          CALL ERROR$I4VAL('NATS EXPECTED',NATS)
          CALL ERROR$STOP('QM-MM$READ')
        END IF
        READ(NFIL)R0(:,:)
        READ(NFIL)RM(:,:)
        READ(NFIL)QEL(:)
      END IF
      CALL MPE$BROADCAST(1,R0)
      CALL MPE$BROADCAST(1,RM)
      CALL MPE$BROADCAST(1,QEL)
      CALL CLASSICAL$SETR8A('R(0)',3*NATS,R0)
      CALL CLASSICAL$SETR8A('R(-)',3*NATS,RM)
      CALL CLASSICAL$SETR8A('QEL',NATS,QEL)
      DEALLOCATE(R0)
      DEALLOCATE(RM)
      DEALLOCATE(QEL)
!
!     == WRITE QMMM ======
      CALL CLASSICAL$SELECT('QMMM')
      ALLOCATE(R0(3,NATM))
      ALLOCATE(RM(3,NATM))
      ALLOCATE(QEL(NATM))
      IF(ITASK.EQ.1) THEN
        READ(NFIL)NAT
        IF(NAT.NE.NATM) THEN
          CALL ERROR$MSG('#(QM-MM ATOMS NOT CONSISTENT')
          CALL ERROR$I4VAL('NATM READ',NAT)
          CALL ERROR$I4VAL('NATM EXPECTED',NATM)
          CALL ERROR$STOP('QMMM$READ')
        END IF
        READ(NFIL)R0(:,:)
        READ(NFIL)RM(:,:)
        READ(NFIL)QEL(:)   !CHARGE WILL NOT BE USED
      END IF
      CALL MPE$BROADCAST(1,R0)
      CALL MPE$BROADCAST(1,RM)
!     CALL MPE$BROADCAST(1,QEL)
      CALL CLASSICAL$SETR8A('R(0)',3*NATM,R0)
      CALL CLASSICAL$SETR8A('R(-)',3*NATM,RM)
!     CALL CLASSICAL$SETR8A('QEL',NATM,QEL)
      DEALLOCATE(R0)
      DEALLOCATE(RM)
      DEALLOCATE(QEL)
      RETURN
      END
