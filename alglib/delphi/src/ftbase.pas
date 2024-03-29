(*************************************************************************
Copyright (c) 2009, Sergey Bochkanov (ALGLIB project).

>>> SOURCE LICENSE >>>
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation (www.fsf.org); either version 2 of the 
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available at
http://www.fsf.org/licensing/licenses

>>> END OF LICENSE >>>
*************************************************************************)
unit ftbase;
interface
uses Math, Sysutils, Ap;

type
FTPlan = record
    Plan : TInteger1DArray;
    Precomputed : TReal1DArray;
    TmpBuf : TReal1DArray;
    StackBuf : TReal1DArray;
end;



procedure FTBaseGenerateComplexFFTPlan(N : AlglibInteger; var Plan : FTPlan);
procedure FTBaseGenerateRealFFTPlan(N : AlglibInteger; var Plan : FTPlan);
procedure FTBaseGenerateRealFHTPlan(N : AlglibInteger; var Plan : FTPlan);
procedure FTBaseExecutePlan(var A : TReal1DArray;
     AOffset : AlglibInteger;
     N : AlglibInteger;
     var Plan : FTPlan);
procedure FTBaseExecutePlanRec(var A : TReal1DArray;
     AOffset : AlglibInteger;
     var Plan : FTPlan;
     EntryOffset : AlglibInteger;
     StackPtr : AlglibInteger);
procedure FTBaseFactorize(N : AlglibInteger;
     TaskType : AlglibInteger;
     var N1 : AlglibInteger;
     var N2 : AlglibInteger);
function FTBaseIsSmooth(N : AlglibInteger):Boolean;
function FTBaseFindSmooth(N : AlglibInteger):AlglibInteger;
function FTBaseFindSmoothEven(N : AlglibInteger):AlglibInteger;
function FTBaseGetFLOPEstimate(N : AlglibInteger):AlglibFloat;

implementation

const
    FTBasePlanEntrySize = 8;
    FTBaseCFFTTask = 0;
    FTBaseRFHTTask = 1;
    FTBaseRFFTTask = 2;
    FFTCooleyTukeyPlan = 0;
    FFTBluesteinPlan = 1;
    FFTCodeletPlan = 2;
    FHTCooleyTukeyPlan = 3;
    FHTCodeletPlan = 4;
    FFTRealCooleyTukeyPlan = 5;
    FFTEmptyPlan = 6;
    FHTN2Plan = 999;
    FTBaseUpdateTw = 4;
    FTBaseCodeletMax = 5;
    FTBaseCodeletRecommended = 5;
    FTBaseInefficiencyFactor = 1.3;
    FTBaseMaxSmoothFactor = 5;

procedure FTBaseGeneratePlanRec(N : AlglibInteger;
     TaskType : AlglibInteger;
     var Plan : FTPlan;
     var PlanSize : AlglibInteger;
     var PrecomputedSize : AlglibInteger;
     var PlanArraySize : AlglibInteger;
     var TmpMemSize : AlglibInteger;
     var StackMemSize : AlglibInteger;
     StackPtr : AlglibInteger);forward;
procedure FTBasePrecomputePlanRec(var Plan : FTPlan;
     EntryOffset : AlglibInteger;
     StackPtr : AlglibInteger);forward;
procedure FFTTwCalc(var A : TReal1DArray;
     AOffset : AlglibInteger;
     N1 : AlglibInteger;
     N2 : AlglibInteger);forward;
procedure InternalComplexLinTranspose(var A : TReal1DArray;
     M : AlglibInteger;
     N : AlglibInteger;
     AStart : AlglibInteger;
     var Buf : TReal1DArray);forward;
procedure InternalRealLinTranspose(var A : TReal1DArray;
     M : AlglibInteger;
     N : AlglibInteger;
     AStart : AlglibInteger;
     var Buf : TReal1DArray);forward;
procedure FFTICLTRec(var A : TReal1DArray;
     AStart : AlglibInteger;
     AStride : AlglibInteger;
     var B : TReal1DArray;
     BStart : AlglibInteger;
     BStride : AlglibInteger;
     M : AlglibInteger;
     N : AlglibInteger);forward;
procedure FFTIRLTRec(var A : TReal1DArray;
     AStart : AlglibInteger;
     AStride : AlglibInteger;
     var B : TReal1DArray;
     BStart : AlglibInteger;
     BStride : AlglibInteger;
     M : AlglibInteger;
     N : AlglibInteger);forward;
procedure FTBaseFindSmoothRec(N : AlglibInteger;
     Seed : AlglibInteger;
     LeastFactor : AlglibInteger;
     var Best : AlglibInteger);forward;
procedure FFTArrayResize(var A : TInteger1DArray;
     var ASize : AlglibInteger;
     NewASize : AlglibInteger);forward;
procedure RefFHT(var A : TReal1DArray;
     N : AlglibInteger;
     Offs : AlglibInteger);forward;


(*************************************************************************
This subroutine generates FFT plan - a decomposition of a N-length FFT to
the more simpler operations. Plan consists of the root entry and the child
entries.

Subroutine parameters:
    N               task size
    
Output parameters:
    Plan            plan

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBaseGenerateComplexFFTPlan(N : AlglibInteger; var Plan : FTPlan);
var
    PlanArraySize : AlglibInteger;
    PlanSize : AlglibInteger;
    PrecomputedSize : AlglibInteger;
    TmpMemSize : AlglibInteger;
    StackMemSize : AlglibInteger;
    StackPtr : AlglibInteger;
begin
    PlanArraySize := 1;
    PlanSize := 0;
    PrecomputedSize := 0;
    StackMemSize := 0;
    StackPtr := 0;
    TmpMemSize := 2*N;
    SetLength(Plan.Plan, PlanArraySize);
    FTBaseGeneratePlanRec(N, FTBaseCFFTTask, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
    Assert(StackPtr=0, 'Internal error in FTBaseGenerateComplexFFTPlan: stack ptr!');
    SetLength(Plan.StackBuf, Max(StackMemSize, 1));
    SetLength(Plan.TmpBuf, Max(TmpMemSize, 1));
    SetLength(Plan.Precomputed, Max(PrecomputedSize, 1));
    StackPtr := 0;
    FTBasePrecomputePlanRec(Plan, 0, StackPtr);
    Assert(StackPtr=0, 'Internal error in FTBaseGenerateComplexFFTPlan: stack ptr!');
end;


(*************************************************************************
Generates real FFT plan
*************************************************************************)
procedure FTBaseGenerateRealFFTPlan(N : AlglibInteger; var Plan : FTPlan);
var
    PlanArraySize : AlglibInteger;
    PlanSize : AlglibInteger;
    PrecomputedSize : AlglibInteger;
    TmpMemSize : AlglibInteger;
    StackMemSize : AlglibInteger;
    StackPtr : AlglibInteger;
begin
    PlanArraySize := 1;
    PlanSize := 0;
    PrecomputedSize := 0;
    StackMemSize := 0;
    StackPtr := 0;
    TmpMemSize := 2*N;
    SetLength(Plan.Plan, PlanArraySize);
    FTBaseGeneratePlanRec(N, FTBaseRFFTTask, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
    Assert(StackPtr=0, 'Internal error in FTBaseGenerateRealFFTPlan: stack ptr!');
    SetLength(Plan.StackBuf, Max(StackMemSize, 1));
    SetLength(Plan.TmpBuf, Max(TmpMemSize, 1));
    SetLength(Plan.Precomputed, Max(PrecomputedSize, 1));
    StackPtr := 0;
    FTBasePrecomputePlanRec(Plan, 0, StackPtr);
    Assert(StackPtr=0, 'Internal error in FTBaseGenerateRealFFTPlan: stack ptr!');
end;


(*************************************************************************
Generates real FHT plan
*************************************************************************)
procedure FTBaseGenerateRealFHTPlan(N : AlglibInteger; var Plan : FTPlan);
var
    PlanArraySize : AlglibInteger;
    PlanSize : AlglibInteger;
    PrecomputedSize : AlglibInteger;
    TmpMemSize : AlglibInteger;
    StackMemSize : AlglibInteger;
    StackPtr : AlglibInteger;
begin
    PlanArraySize := 1;
    PlanSize := 0;
    PrecomputedSize := 0;
    StackMemSize := 0;
    StackPtr := 0;
    TmpMemSize := N;
    SetLength(Plan.Plan, PlanArraySize);
    FTBaseGeneratePlanRec(N, FTBaseRFHTTask, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
    Assert(StackPtr=0, 'Internal error in FTBaseGenerateRealFHTPlan: stack ptr!');
    SetLength(Plan.StackBuf, Max(StackMemSize, 1));
    SetLength(Plan.TmpBuf, Max(TmpMemSize, 1));
    SetLength(Plan.Precomputed, Max(PrecomputedSize, 1));
    StackPtr := 0;
    FTBasePrecomputePlanRec(Plan, 0, StackPtr);
    Assert(StackPtr=0, 'Internal error in FTBaseGenerateRealFHTPlan: stack ptr!');
end;


(*************************************************************************
This subroutine executes FFT/FHT plan.

If Plan is a:
* complex FFT plan  -   sizeof(A)=2*N,
                        A contains interleaved real/imaginary values
* real FFT plan     -   sizeof(A)=2*N,
                        A contains real values interleaved with zeros
* real FHT plan     -   sizeof(A)=2*N,
                        A contains real values interleaved with zeros

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBaseExecutePlan(var A : TReal1DArray;
     AOffset : AlglibInteger;
     N : AlglibInteger;
     var Plan : FTPlan);
var
    StackPtr : AlglibInteger;
begin
    StackPtr := 0;
    FTBaseExecutePlanRec(A, AOffset, Plan, 0, StackPtr);
end;


(*************************************************************************
Recurrent subroutine for the FTBaseExecutePlan

Parameters:
    A           FFT'ed array
    AOffset     offset of the FFT'ed part (distance is measured in doubles)

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBaseExecutePlanRec(var A : TReal1DArray;
     AOffset : AlglibInteger;
     var Plan : FTPlan;
     EntryOffset : AlglibInteger;
     StackPtr : AlglibInteger);
var
    I : AlglibInteger;
    J : AlglibInteger;
    K : AlglibInteger;
    N1 : AlglibInteger;
    N2 : AlglibInteger;
    N : AlglibInteger;
    M : AlglibInteger;
    Offs : AlglibInteger;
    Offs1 : AlglibInteger;
    Offs2 : AlglibInteger;
    OffsA : AlglibInteger;
    OffsB : AlglibInteger;
    OffsP : AlglibInteger;
    HK : AlglibFloat;
    HNK : AlglibFloat;
    X : AlglibFloat;
    Y : AlglibFloat;
    BX : AlglibFloat;
    BY : AlglibFloat;
    EmptyArray : TReal1DArray;
    A0X : AlglibFloat;
    A0Y : AlglibFloat;
    A1X : AlglibFloat;
    A1Y : AlglibFloat;
    A2X : AlglibFloat;
    A2Y : AlglibFloat;
    A3X : AlglibFloat;
    A3Y : AlglibFloat;
    V0 : AlglibFloat;
    V1 : AlglibFloat;
    V2 : AlglibFloat;
    V3 : AlglibFloat;
    T1X : AlglibFloat;
    T1Y : AlglibFloat;
    T2X : AlglibFloat;
    T2Y : AlglibFloat;
    T3X : AlglibFloat;
    T3Y : AlglibFloat;
    T4X : AlglibFloat;
    T4Y : AlglibFloat;
    T5X : AlglibFloat;
    T5Y : AlglibFloat;
    M1X : AlglibFloat;
    M1Y : AlglibFloat;
    M2X : AlglibFloat;
    M2Y : AlglibFloat;
    M3X : AlglibFloat;
    M3Y : AlglibFloat;
    M4X : AlglibFloat;
    M4Y : AlglibFloat;
    M5X : AlglibFloat;
    M5Y : AlglibFloat;
    S1X : AlglibFloat;
    S1Y : AlglibFloat;
    S2X : AlglibFloat;
    S2Y : AlglibFloat;
    S3X : AlglibFloat;
    S3Y : AlglibFloat;
    S4X : AlglibFloat;
    S4Y : AlglibFloat;
    S5X : AlglibFloat;
    S5Y : AlglibFloat;
    C1 : AlglibFloat;
    C2 : AlglibFloat;
    C3 : AlglibFloat;
    C4 : AlglibFloat;
    C5 : AlglibFloat;
    Tmp : TReal1DArray;
begin
    if Plan.Plan[EntryOffset+3]=FFTEmptyPlan then
    begin
        Exit;
    end;
    if Plan.Plan[EntryOffset+3]=FFTCooleyTukeyPlan then
    begin
        
        //
        // Cooley-Tukey plan
        // * transposition
        // * row-wise FFT
        // * twiddle factors:
        //   - TwBase is a basis twiddle factor for I=1, J=1
        //   - TwRow is a twiddle factor for a second element in a row (J=1)
        //   - Tw is a twiddle factor for a current element
        // * transposition again
        // * row-wise FFT again
        //
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        InternalComplexLinTranspose(A, N1, N2, AOffset, Plan.TmpBuf);
        I:=0;
        while I<=N2-1 do
        begin
            FTBaseExecutePlanRec(A, AOffset+I*N1*2, Plan, Plan.Plan[EntryOffset+5], StackPtr);
            Inc(I);
        end;
        FFTTwCalc(A, AOffset, N1, N2);
        InternalComplexLinTranspose(A, N2, N1, AOffset, Plan.TmpBuf);
        I:=0;
        while I<=N1-1 do
        begin
            FTBaseExecutePlanRec(A, AOffset+I*N2*2, Plan, Plan.Plan[EntryOffset+6], StackPtr);
            Inc(I);
        end;
        InternalComplexLinTranspose(A, N1, N2, AOffset, Plan.TmpBuf);
        Exit;
    end;
    if Plan.Plan[EntryOffset+3]=FFTRealCooleyTukeyPlan then
    begin
        
        //
        // Cooley-Tukey plan
        // * transposition
        // * row-wise FFT
        // * twiddle factors:
        //   - TwBase is a basis twiddle factor for I=1, J=1
        //   - TwRow is a twiddle factor for a second element in a row (J=1)
        //   - Tw is a twiddle factor for a current element
        // * transposition again
        // * row-wise FFT again
        //
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        InternalComplexLinTranspose(A, N2, N1, AOffset, Plan.TmpBuf);
        I:=0;
        while I<=N1 div 2-1 do
        begin
            
            //
            // pack two adjacent smaller real FFT's together,
            // make one complex FFT,
            // unpack result
            //
            Offs := AOffset+2*I*N2*2;
            K:=0;
            while K<=N2-1 do
            begin
                A[Offs+2*K+1] := A[Offs+2*N2+2*K+0];
                Inc(K);
            end;
            FTBaseExecutePlanRec(A, Offs, Plan, Plan.Plan[EntryOffset+6], StackPtr);
            Plan.TmpBuf[0] := A[Offs+0];
            Plan.TmpBuf[1] := 0;
            Plan.TmpBuf[2*N2+0] := A[Offs+1];
            Plan.TmpBuf[2*N2+1] := 0;
            K:=1;
            while K<=N2-1 do
            begin
                Offs1 := 2*K;
                Offs2 := 2*N2+2*K;
                HK := A[Offs+2*K+0];
                HNK := A[Offs+2*(N2-K)+0];
                Plan.TmpBuf[Offs1+0] := +0.5*(HK+HNK);
                Plan.TmpBuf[Offs2+1] := -0.5*(HK-HNK);
                HK := A[Offs+2*K+1];
                HNK := A[Offs+2*(N2-K)+1];
                Plan.TmpBuf[Offs2+0] := +0.5*(HK+HNK);
                Plan.TmpBuf[Offs1+1] := +0.5*(HK-HNK);
                Inc(K);
            end;
            APVMove(@A[0], Offs, Offs+2*N2*2-1, @Plan.TmpBuf[0], 0, 2*N2*2-1);
            Inc(I);
        end;
        if N1 mod 2<>0 then
        begin
            FTBaseExecutePlanRec(A, AOffset+(N1-1)*N2*2, Plan, Plan.Plan[EntryOffset+6], StackPtr);
        end;
        FFTTwCalc(A, AOffset, N2, N1);
        InternalComplexLinTranspose(A, N1, N2, AOffset, Plan.TmpBuf);
        I:=0;
        while I<=N2-1 do
        begin
            FTBaseExecutePlanRec(A, AOffset+I*N1*2, Plan, Plan.Plan[EntryOffset+5], StackPtr);
            Inc(I);
        end;
        InternalComplexLinTranspose(A, N2, N1, AOffset, Plan.TmpBuf);
        Exit;
    end;
    if Plan.Plan[EntryOffset+3]=FHTCooleyTukeyPlan then
    begin
        
        //
        // Cooley-Tukey FHT plan:
        // * transpose                    \
        // * smaller FHT's                |
        // * pre-process                  |
        // * multiply by twiddle factors  | corresponds to multiplication by H1
        // * post-process                 |
        // * transpose again              /
        // * multiply by H2 (smaller FHT's)
        // * final transposition
        //
        // For more details see Vitezslav Vesely, "Fast algorithms
        // of Fourier and Hartley transform and their implementation in MATLAB",
        // page 31.
        //
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        N := N1*N2;
        InternalRealLinTranspose(A, N1, N2, AOffset, Plan.TmpBuf);
        I:=0;
        while I<=N2-1 do
        begin
            FTBaseExecutePlanRec(A, AOffset+I*N1, Plan, Plan.Plan[EntryOffset+5], StackPtr);
            Inc(I);
        end;
        I:=0;
        while I<=N2-1 do
        begin
            J:=0;
            while J<=N1-1 do
            begin
                OffsA := AOffset+I*N1;
                HK := A[OffsA+J];
                HNK := A[OffsA+(N1-J) mod N1];
                Offs := 2*(I*N1+J);
                Plan.TmpBuf[Offs+0] := -0.5*(HNK-HK);
                Plan.TmpBuf[Offs+1] := +0.5*(HK+HNK);
                Inc(J);
            end;
            Inc(I);
        end;
        FFTTwCalc(Plan.TmpBuf, 0, N1, N2);
        J:=0;
        while J<=N1-1 do
        begin
            A[AOffset+J] := Plan.TmpBuf[2*J+0]+Plan.TmpBuf[2*J+1];
            Inc(J);
        end;
        if N2 mod 2=0 then
        begin
            Offs := 2*(N2 div 2)*N1;
            OffsA := AOffset+N2 div 2*N1;
            J:=0;
            while J<=N1-1 do
            begin
                A[OffsA+J] := Plan.TmpBuf[Offs+2*J+0]+Plan.TmpBuf[Offs+2*J+1];
                Inc(J);
            end;
        end;
        I:=1;
        while I<=(N2+1) div 2-1 do
        begin
            Offs := 2*I*N1;
            Offs2 := 2*(N2-I)*N1;
            OffsA := AOffset+I*N1;
            J:=0;
            while J<=N1-1 do
            begin
                A[OffsA+J] := Plan.TmpBuf[Offs+2*J+1]+Plan.TmpBuf[Offs2+2*J+0];
                Inc(J);
            end;
            OffsA := AOffset+(N2-I)*N1;
            J:=0;
            while J<=N1-1 do
            begin
                A[OffsA+J] := Plan.TmpBuf[Offs+2*J+0]+Plan.TmpBuf[Offs2+2*J+1];
                Inc(J);
            end;
            Inc(I);
        end;
        InternalRealLinTranspose(A, N2, N1, AOffset, Plan.TmpBuf);
        I:=0;
        while I<=N1-1 do
        begin
            FTBaseExecutePlanRec(A, AOffset+I*N2, Plan, Plan.Plan[EntryOffset+6], StackPtr);
            Inc(I);
        end;
        InternalRealLinTranspose(A, N1, N2, AOffset, Plan.TmpBuf);
        Exit;
    end;
    if Plan.Plan[EntryOffset+3]=FHTN2Plan then
    begin
        
        //
        // Cooley-Tukey FHT plan
        //
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        N := N1*N2;
        RefFHT(A, N, AOffset);
        Exit;
    end;
    if Plan.Plan[EntryOffset+3]=FFTCodeletPlan then
    begin
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        N := N1*N2;
        if N=2 then
        begin
            A0X := A[AOffset+0];
            A0Y := A[AOffset+1];
            A1X := A[AOffset+2];
            A1Y := A[AOffset+3];
            V0 := A0X+A1X;
            V1 := A0Y+A1Y;
            V2 := A0X-A1X;
            V3 := A0Y-A1Y;
            A[AOffset+0] := V0;
            A[AOffset+1] := V1;
            A[AOffset+2] := V2;
            A[AOffset+3] := V3;
            Exit;
        end;
        if N=3 then
        begin
            Offs := Plan.Plan[EntryOffset+7];
            C1 := Plan.Precomputed[Offs+0];
            C2 := Plan.Precomputed[Offs+1];
            A0X := A[AOffset+0];
            A0Y := A[AOffset+1];
            A1X := A[AOffset+2];
            A1Y := A[AOffset+3];
            A2X := A[AOffset+4];
            A2Y := A[AOffset+5];
            T1X := A1X+A2X;
            T1Y := A1Y+A2Y;
            A0X := A0X+T1X;
            A0Y := A0Y+T1Y;
            M1X := C1*T1X;
            M1Y := C1*T1Y;
            M2X := C2*(A1Y-A2Y);
            M2Y := C2*(A2X-A1X);
            S1X := A0X+M1X;
            S1Y := A0Y+M1Y;
            A1X := S1X+M2X;
            A1Y := S1Y+M2Y;
            A2X := S1X-M2X;
            A2Y := S1Y-M2Y;
            A[AOffset+0] := A0X;
            A[AOffset+1] := A0Y;
            A[AOffset+2] := A1X;
            A[AOffset+3] := A1Y;
            A[AOffset+4] := A2X;
            A[AOffset+5] := A2Y;
            Exit;
        end;
        if N=4 then
        begin
            A0X := A[AOffset+0];
            A0Y := A[AOffset+1];
            A1X := A[AOffset+2];
            A1Y := A[AOffset+3];
            A2X := A[AOffset+4];
            A2Y := A[AOffset+5];
            A3X := A[AOffset+6];
            A3Y := A[AOffset+7];
            T1X := A0X+A2X;
            T1Y := A0Y+A2Y;
            T2X := A1X+A3X;
            T2Y := A1Y+A3Y;
            M2X := A0X-A2X;
            M2Y := A0Y-A2Y;
            M3X := A1Y-A3Y;
            M3Y := A3X-A1X;
            A[AOffset+0] := T1X+T2X;
            A[AOffset+1] := T1Y+T2Y;
            A[AOffset+4] := T1X-T2X;
            A[AOffset+5] := T1Y-T2Y;
            A[AOffset+2] := M2X+M3X;
            A[AOffset+3] := M2Y+M3Y;
            A[AOffset+6] := M2X-M3X;
            A[AOffset+7] := M2Y-M3Y;
            Exit;
        end;
        if N=5 then
        begin
            Offs := Plan.Plan[EntryOffset+7];
            C1 := Plan.Precomputed[Offs+0];
            C2 := Plan.Precomputed[Offs+1];
            C3 := Plan.Precomputed[Offs+2];
            C4 := Plan.Precomputed[Offs+3];
            C5 := Plan.Precomputed[Offs+4];
            T1X := A[AOffset+2]+A[AOffset+8];
            T1Y := A[AOffset+3]+A[AOffset+9];
            T2X := A[AOffset+4]+A[AOffset+6];
            T2Y := A[AOffset+5]+A[AOffset+7];
            T3X := A[AOffset+2]-A[AOffset+8];
            T3Y := A[AOffset+3]-A[AOffset+9];
            T4X := A[AOffset+6]-A[AOffset+4];
            T4Y := A[AOffset+7]-A[AOffset+5];
            T5X := T1X+T2X;
            T5Y := T1Y+T2Y;
            A[AOffset+0] := A[AOffset+0]+T5X;
            A[AOffset+1] := A[AOffset+1]+T5Y;
            M1X := C1*T5X;
            M1Y := C1*T5Y;
            M2X := C2*(T1X-T2X);
            M2Y := C2*(T1Y-T2Y);
            M3X := -C3*(T3Y+T4Y);
            M3Y := C3*(T3X+T4X);
            M4X := -C4*T4Y;
            M4Y := C4*T4X;
            M5X := -C5*T3Y;
            M5Y := C5*T3X;
            S3X := M3X-M4X;
            S3Y := M3Y-M4Y;
            S5X := M3X+M5X;
            S5Y := M3Y+M5Y;
            S1X := A[AOffset+0]+M1X;
            S1Y := A[AOffset+1]+M1Y;
            S2X := S1X+M2X;
            S2Y := S1Y+M2Y;
            S4X := S1X-M2X;
            S4Y := S1Y-M2Y;
            A[AOffset+2] := S2X+S3X;
            A[AOffset+3] := S2Y+S3Y;
            A[AOffset+4] := S4X+S5X;
            A[AOffset+5] := S4Y+S5Y;
            A[AOffset+6] := S4X-S5X;
            A[AOffset+7] := S4Y-S5Y;
            A[AOffset+8] := S2X-S3X;
            A[AOffset+9] := S2Y-S3Y;
            Exit;
        end;
    end;
    if Plan.Plan[EntryOffset+3]=FHTCodeletPlan then
    begin
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        N := N1*N2;
        if N=2 then
        begin
            A0X := A[AOffset+0];
            A1X := A[AOffset+1];
            A[AOffset+0] := A0X+A1X;
            A[AOffset+1] := A0X-A1X;
            Exit;
        end;
        if N=3 then
        begin
            Offs := Plan.Plan[EntryOffset+7];
            C1 := Plan.Precomputed[Offs+0];
            C2 := Plan.Precomputed[Offs+1];
            A0X := A[AOffset+0];
            A1X := A[AOffset+1];
            A2X := A[AOffset+2];
            T1X := A1X+A2X;
            A0X := A0X+T1X;
            M1X := C1*T1X;
            M2Y := C2*(A2X-A1X);
            S1X := A0X+M1X;
            A[AOffset+0] := A0X;
            A[AOffset+1] := S1X-M2Y;
            A[AOffset+2] := S1X+M2Y;
            Exit;
        end;
        if N=4 then
        begin
            A0X := A[AOffset+0];
            A1X := A[AOffset+1];
            A2X := A[AOffset+2];
            A3X := A[AOffset+3];
            T1X := A0X+A2X;
            T2X := A1X+A3X;
            M2X := A0X-A2X;
            M3Y := A3X-A1X;
            A[AOffset+0] := T1X+T2X;
            A[AOffset+1] := M2X-M3Y;
            A[AOffset+2] := T1X-T2X;
            A[AOffset+3] := M2X+M3Y;
            Exit;
        end;
        if N=5 then
        begin
            Offs := Plan.Plan[EntryOffset+7];
            C1 := Plan.Precomputed[Offs+0];
            C2 := Plan.Precomputed[Offs+1];
            C3 := Plan.Precomputed[Offs+2];
            C4 := Plan.Precomputed[Offs+3];
            C5 := Plan.Precomputed[Offs+4];
            T1X := A[AOffset+1]+A[AOffset+4];
            T2X := A[AOffset+2]+A[AOffset+3];
            T3X := A[AOffset+1]-A[AOffset+4];
            T4X := A[AOffset+3]-A[AOffset+2];
            T5X := T1X+T2X;
            V0 := A[AOffset+0]+T5X;
            A[AOffset+0] := V0;
            M2X := C2*(T1X-T2X);
            M3Y := C3*(T3X+T4X);
            S3Y := M3Y-C4*T4X;
            S5Y := M3Y+C5*T3X;
            S1X := V0+C1*T5X;
            S2X := S1X+M2X;
            S4X := S1X-M2X;
            A[AOffset+1] := S2X-S3Y;
            A[AOffset+2] := S4X-S5Y;
            A[AOffset+3] := S4X+S5Y;
            A[AOffset+4] := S2X+S3Y;
            Exit;
        end;
    end;
    if Plan.Plan[EntryOffset+3]=FFTBluesteinPlan then
    begin
        
        //
        // Bluestein plan:
        // 1. multiply by precomputed coefficients
        // 2. make convolution: forward FFT, multiplication by precomputed FFT
        //    and backward FFT. backward FFT is represented as
        //
        //        invfft(x) = fft(x')'/M
        //
        //    for performance reasons reduction of inverse FFT to
        //    forward FFT is merged with multiplication of FFT components
        //    and last stage of Bluestein's transformation.
        // 3. post-multiplication by Bluestein factors
        //
        N := Plan.Plan[EntryOffset+1];
        M := Plan.Plan[EntryOffset+4];
        Offs := Plan.Plan[EntryOffset+7];
        I:=StackPtr+2*N;
        while I<=StackPtr+2*M-1 do
        begin
            Plan.StackBuf[I] := 0;
            Inc(I);
        end;
        OffsP := Offs+2*M;
        OffsA := AOffset;
        OffsB := StackPtr;
        I:=0;
        while I<=N-1 do
        begin
            BX := Plan.Precomputed[OffsP+0];
            BY := Plan.Precomputed[OffsP+1];
            X := A[OffsA+0];
            Y := A[OffsA+1];
            Plan.StackBuf[OffsB+0] := X*BX-Y*-BY;
            Plan.StackBuf[OffsB+1] := X*-BY+Y*BX;
            OffsP := OffsP+2;
            OffsA := OffsA+2;
            OffsB := OffsB+2;
            Inc(I);
        end;
        FTBaseExecutePlanRec(Plan.StackBuf, StackPtr, Plan, Plan.Plan[EntryOffset+5], StackPtr+2*2*M);
        OffsB := StackPtr;
        OffsP := Offs;
        I:=0;
        while I<=M-1 do
        begin
            X := Plan.StackBuf[OffsB+0];
            Y := Plan.StackBuf[OffsB+1];
            BX := Plan.Precomputed[OffsP+0];
            BY := Plan.Precomputed[OffsP+1];
            Plan.StackBuf[OffsB+0] := X*BX-Y*BY;
            Plan.StackBuf[OffsB+1] := -(X*BY+Y*BX);
            OffsB := OffsB+2;
            OffsP := OffsP+2;
            Inc(I);
        end;
        FTBaseExecutePlanRec(Plan.StackBuf, StackPtr, Plan, Plan.Plan[EntryOffset+5], StackPtr+2*2*M);
        OffsB := StackPtr;
        OffsP := Offs+2*M;
        OffsA := AOffset;
        I:=0;
        while I<=N-1 do
        begin
            X := +Plan.StackBuf[OffsB+0]/M;
            Y := -Plan.StackBuf[OffsB+1]/M;
            BX := Plan.Precomputed[OffsP+0];
            BY := Plan.Precomputed[OffsP+1];
            A[OffsA+0] := X*BX-Y*-BY;
            A[OffsA+1] := X*-BY+Y*BX;
            OffsP := OffsP+2;
            OffsA := OffsA+2;
            OffsB := OffsB+2;
            Inc(I);
        end;
        Exit;
    end;
end;


(*************************************************************************
Returns good factorization N=N1*N2.

Usually N1<=N2 (but not always - small N's may be exception).
if N1<>1 then N2<>1.

Factorization is chosen depending on task type and codelets we have.

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBaseFactorize(N : AlglibInteger;
     TaskType : AlglibInteger;
     var N1 : AlglibInteger;
     var N2 : AlglibInteger);
var
    J : AlglibInteger;
begin
    N1 := 0;
    N2 := 0;
    
    //
    // try to find good codelet
    //
    if N1*N2<>N then
    begin
        J:=FTBaseCodeletRecommended;
        while J>=2 do
        begin
            if N mod J=0 then
            begin
                N1 := J;
                N2 := N div J;
                Break;
            end;
            Dec(J);
        end;
    end;
    
    //
    // try to factorize N
    //
    if N1*N2<>N then
    begin
        J:=FTBaseCodeletRecommended+1;
        while J<=N-1 do
        begin
            if N mod J=0 then
            begin
                N1 := J;
                N2 := N div J;
                Break;
            end;
            Inc(J);
        end;
    end;
    
    //
    // looks like N is prime :(
    //
    if N1*N2<>N then
    begin
        N1 := 1;
        N2 := N;
    end;
    
    //
    // normalize
    //
    if (N2=1) and (N1<>1) then
    begin
        N2 := N1;
        N1 := 1;
    end;
end;


(*************************************************************************
Is number smooth?

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
function FTBaseIsSmooth(N : AlglibInteger):Boolean;
var
    I : AlglibInteger;
begin
    I:=2;
    while I<=FTBaseMaxSmoothFactor do
    begin
        while N mod I=0 do
        begin
            N := N div I;
        end;
        Inc(I);
    end;
    Result := N=1;
end;


(*************************************************************************
Returns smallest smooth (divisible only by 2, 3, 5) number that is greater
than or equal to max(N,2)

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
function FTBaseFindSmooth(N : AlglibInteger):AlglibInteger;
var
    Best : AlglibInteger;
begin
    Best := 2;
    while Best<N do
    begin
        Best := 2*Best;
    end;
    FTBaseFindSmoothRec(N, 1, 2, Best);
    Result := Best;
end;


(*************************************************************************
Returns  smallest  smooth  (divisible only by 2, 3, 5) even number that is
greater than or equal to max(N,2)

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
function FTBaseFindSmoothEven(N : AlglibInteger):AlglibInteger;
var
    Best : AlglibInteger;
begin
    Best := 2;
    while Best<N do
    begin
        Best := 2*Best;
    end;
    FTBaseFindSmoothRec(N, 2, 2, Best);
    Result := Best;
end;


(*************************************************************************
Returns estimate of FLOP count for the FFT.

It is only an estimate based on operations count for the PERFECT FFT
and relative inefficiency of the algorithm actually used.

N should be power of 2, estimates are badly wrong for non-power-of-2 N's.

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
function FTBaseGetFLOPEstimate(N : AlglibInteger):AlglibFloat;
begin
    Result := FTBaseInefficiencyFactor*(4*N*Ln(N)/Ln(2)-6*N+8);
end;


(*************************************************************************
Recurrent subroutine for the FFTGeneratePlan:

PARAMETERS:
    N                   plan size
    IsReal              whether input is real or not.
                        subroutine MUST NOT ignore this flag because real
                        inputs comes with non-initialized imaginary parts,
                        so ignoring this flag will result in corrupted output
    HalfOut             whether full output or only half of it from 0 to
                        floor(N/2) is needed. This flag may be ignored if
                        doing so will simplify calculations
    Plan                plan array
    PlanSize            size of used part (in integers)
    PrecomputedSize     size of precomputed array allocated yet
    PlanArraySize       plan array size (actual)
    TmpMemSize          temporary memory required size
    BluesteinMemSize    temporary memory required size

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBaseGeneratePlanRec(N : AlglibInteger;
     TaskType : AlglibInteger;
     var Plan : FTPlan;
     var PlanSize : AlglibInteger;
     var PrecomputedSize : AlglibInteger;
     var PlanArraySize : AlglibInteger;
     var TmpMemSize : AlglibInteger;
     var StackMemSize : AlglibInteger;
     StackPtr : AlglibInteger);
var
    K : AlglibInteger;
    M : AlglibInteger;
    N1 : AlglibInteger;
    N2 : AlglibInteger;
    ESize : AlglibInteger;
    EntryOffset : AlglibInteger;
begin
    
    //
    // prepare
    //
    if PlanSize+FTBasePlanEntrySize>PlanArraySize then
    begin
        FFTArrayResize(Plan.Plan, PlanArraySize, 8*PlanArraySize);
    end;
    EntryOffset := PlanSize;
    ESize := FTBasePlanEntrySize;
    PlanSize := PlanSize+ESize;
    
    //
    // if N=1, generate empty plan and exit
    //
    if N=1 then
    begin
        Plan.Plan[EntryOffset+0] := ESize;
        Plan.Plan[EntryOffset+1] := -1;
        Plan.Plan[EntryOffset+2] := -1;
        Plan.Plan[EntryOffset+3] := FFTEmptyPlan;
        Plan.Plan[EntryOffset+4] := -1;
        Plan.Plan[EntryOffset+5] := -1;
        Plan.Plan[EntryOffset+6] := -1;
        Plan.Plan[EntryOffset+7] := -1;
        Exit;
    end;
    
    //
    // generate plans
    //
    FTBaseFactorize(N, TaskType, N1, N2);
    if (TaskType=FTBaseCFFTTask) or (TaskType=FTBaseRFFTTask) then
    begin
        
        //
        // complex FFT plans
        //
        if N1<>1 then
        begin
            
            //
            // Cooley-Tukey plan (real or complex)
            //
            // Note that child plans are COMPLEX
            // (whether plan itself is complex or not).
            //
            TmpMemSize := Max(TmpMemSize, 2*N1*N2);
            Plan.Plan[EntryOffset+0] := ESize;
            Plan.Plan[EntryOffset+1] := N1;
            Plan.Plan[EntryOffset+2] := N2;
            if TaskType=FTBaseCFFTTask then
            begin
                Plan.Plan[EntryOffset+3] := FFTCooleyTukeyPlan;
            end
            else
            begin
                Plan.Plan[EntryOffset+3] := FFTRealCooleyTukeyPlan;
            end;
            Plan.Plan[EntryOffset+4] := 0;
            Plan.Plan[EntryOffset+5] := PlanSize;
            FTBaseGeneratePlanRec(N1, FTBaseCFFTTask, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
            Plan.Plan[EntryOffset+6] := PlanSize;
            FTBaseGeneratePlanRec(N2, FTBaseCFFTTask, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
            Plan.Plan[EntryOffset+7] := -1;
            Exit;
        end
        else
        begin
            if (N=2) or (N=3) or (N=4) or (N=5) then
            begin
                
                //
                // hard-coded plan
                //
                Plan.Plan[EntryOffset+0] := ESize;
                Plan.Plan[EntryOffset+1] := N1;
                Plan.Plan[EntryOffset+2] := N2;
                Plan.Plan[EntryOffset+3] := FFTCodeletPlan;
                Plan.Plan[EntryOffset+4] := 0;
                Plan.Plan[EntryOffset+5] := -1;
                Plan.Plan[EntryOffset+6] := -1;
                Plan.Plan[EntryOffset+7] := PrecomputedSize;
                if N=3 then
                begin
                    PrecomputedSize := PrecomputedSize+2;
                end;
                if N=5 then
                begin
                    PrecomputedSize := PrecomputedSize+5;
                end;
                Exit;
            end
            else
            begin
                
                //
                // Bluestein's plan
                //
                // Select such M that M>=2*N-1, M is composite, and M's
                // factors are 2, 3, 5
                //
                K := 2*N2-1;
                M := FTBaseFindSmooth(K);
                TmpMemSize := Max(TmpMemSize, 2*M);
                Plan.Plan[EntryOffset+0] := ESize;
                Plan.Plan[EntryOffset+1] := N2;
                Plan.Plan[EntryOffset+2] := -1;
                Plan.Plan[EntryOffset+3] := FFTBluesteinPlan;
                Plan.Plan[EntryOffset+4] := M;
                Plan.Plan[EntryOffset+5] := PlanSize;
                StackPtr := StackPtr+2*2*M;
                StackMemSize := Max(StackMemSize, StackPtr);
                FTBaseGeneratePlanRec(M, FTBaseCFFTTask, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
                StackPtr := StackPtr-2*2*M;
                Plan.Plan[EntryOffset+6] := -1;
                Plan.Plan[EntryOffset+7] := PrecomputedSize;
                PrecomputedSize := PrecomputedSize+2*M+2*N;
                Exit;
            end;
        end;
    end;
    if TaskType=FTBaseRFHTTask then
    begin
        
        //
        // real FHT plans
        //
        if N1<>1 then
        begin
            
            //
            // Cooley-Tukey plan
            //
            //
            TmpMemSize := Max(TmpMemSize, 2*N1*N2);
            Plan.Plan[EntryOffset+0] := ESize;
            Plan.Plan[EntryOffset+1] := N1;
            Plan.Plan[EntryOffset+2] := N2;
            Plan.Plan[EntryOffset+3] := FHTCooleyTukeyPlan;
            Plan.Plan[EntryOffset+4] := 0;
            Plan.Plan[EntryOffset+5] := PlanSize;
            FTBaseGeneratePlanRec(N1, TaskType, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
            Plan.Plan[EntryOffset+6] := PlanSize;
            FTBaseGeneratePlanRec(N2, TaskType, Plan, PlanSize, PrecomputedSize, PlanArraySize, TmpMemSize, StackMemSize, StackPtr);
            Plan.Plan[EntryOffset+7] := -1;
            Exit;
        end
        else
        begin
            
            //
            // N2 plan
            //
            Plan.Plan[EntryOffset+0] := ESize;
            Plan.Plan[EntryOffset+1] := N1;
            Plan.Plan[EntryOffset+2] := N2;
            Plan.Plan[EntryOffset+3] := FHTN2Plan;
            Plan.Plan[EntryOffset+4] := 0;
            Plan.Plan[EntryOffset+5] := -1;
            Plan.Plan[EntryOffset+6] := -1;
            Plan.Plan[EntryOffset+7] := -1;
            if (N=2) or (N=3) or (N=4) or (N=5) then
            begin
                
                //
                // hard-coded plan
                //
                Plan.Plan[EntryOffset+0] := ESize;
                Plan.Plan[EntryOffset+1] := N1;
                Plan.Plan[EntryOffset+2] := N2;
                Plan.Plan[EntryOffset+3] := FHTCodeletPlan;
                Plan.Plan[EntryOffset+4] := 0;
                Plan.Plan[EntryOffset+5] := -1;
                Plan.Plan[EntryOffset+6] := -1;
                Plan.Plan[EntryOffset+7] := PrecomputedSize;
                if N=3 then
                begin
                    PrecomputedSize := PrecomputedSize+2;
                end;
                if N=5 then
                begin
                    PrecomputedSize := PrecomputedSize+5;
                end;
                Exit;
            end;
            Exit;
        end;
    end;
end;


(*************************************************************************
Recurrent subroutine for precomputing FFT plans

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBasePrecomputePlanRec(var Plan : FTPlan;
     EntryOffset : AlglibInteger;
     StackPtr : AlglibInteger);
var
    I : AlglibInteger;
    Idx : AlglibInteger;
    N1 : AlglibInteger;
    N2 : AlglibInteger;
    N : AlglibInteger;
    M : AlglibInteger;
    Offs : AlglibInteger;
    V : AlglibFloat;
    EmptyArray : TReal1DArray;
    BX : AlglibFloat;
    BY : AlglibFloat;
begin
    if (Plan.Plan[EntryOffset+3]=FFTCooleyTukeyPlan) or (Plan.Plan[EntryOffset+3]=FFTRealCooleyTukeyPlan) or (Plan.Plan[EntryOffset+3]=FHTCooleyTukeyPlan) then
    begin
        FTBasePrecomputePlanRec(Plan, Plan.Plan[EntryOffset+5], StackPtr);
        FTBasePrecomputePlanRec(Plan, Plan.Plan[EntryOffset+6], StackPtr);
        Exit;
    end;
    if (Plan.Plan[EntryOffset+3]=FFTCodeletPlan) or (Plan.Plan[EntryOffset+3]=FHTCodeletPlan) then
    begin
        N1 := Plan.Plan[EntryOffset+1];
        N2 := Plan.Plan[EntryOffset+2];
        N := N1*N2;
        if N=3 then
        begin
            Offs := Plan.Plan[EntryOffset+7];
            Plan.Precomputed[Offs+0] := Cos(2*Pi/3)-1;
            Plan.Precomputed[Offs+1] := Sin(2*Pi/3);
            Exit;
        end;
        if N=5 then
        begin
            Offs := Plan.Plan[EntryOffset+7];
            V := 2*Pi/5;
            Plan.Precomputed[Offs+0] := (cos(V)+cos(2*V))/2-1;
            Plan.Precomputed[Offs+1] := (cos(V)-cos(2*V))/2;
            Plan.Precomputed[Offs+2] := -sin(V);
            Plan.Precomputed[Offs+3] := -(sin(V)+sin(2*V));
            Plan.Precomputed[Offs+4] := sin(V)-sin(2*V);
            Exit;
        end;
    end;
    if Plan.Plan[EntryOffset+3]=FFTBluesteinPlan then
    begin
        FTBasePrecomputePlanRec(Plan, Plan.Plan[EntryOffset+5], StackPtr);
        N := Plan.Plan[EntryOffset+1];
        M := Plan.Plan[EntryOffset+4];
        Offs := Plan.Plan[EntryOffset+7];
        I:=0;
        while I<=2*M-1 do
        begin
            Plan.Precomputed[Offs+I] := 0;
            Inc(I);
        end;
        I:=0;
        while I<=N-1 do
        begin
            BX := Cos(Pi*AP_Sqr(I)/N);
            BY := Sin(Pi*AP_Sqr(I)/N);
            Plan.Precomputed[Offs+2*I+0] := BX;
            Plan.Precomputed[Offs+2*I+1] := BY;
            Plan.Precomputed[Offs+2*M+2*I+0] := BX;
            Plan.Precomputed[Offs+2*M+2*I+1] := BY;
            if I>0 then
            begin
                Plan.Precomputed[Offs+2*(M-I)+0] := BX;
                Plan.Precomputed[Offs+2*(M-I)+1] := BY;
            end;
            Inc(I);
        end;
        FTBaseExecutePlanRec(Plan.Precomputed, Offs, Plan, Plan.Plan[EntryOffset+5], StackPtr);
        Exit;
    end;
end;


(*************************************************************************
Twiddle factors calculation

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FFTTwCalc(var A : TReal1DArray;
     AOffset : AlglibInteger;
     N1 : AlglibInteger;
     N2 : AlglibInteger);
var
    I : AlglibInteger;
    J : AlglibInteger;
    N : AlglibInteger;
    Idx : AlglibInteger;
    Offs : AlglibInteger;
    X : AlglibFloat;
    Y : AlglibFloat;
    TwXM1 : AlglibFloat;
    TwY : AlglibFloat;
    TwBaseXM1 : AlglibFloat;
    TwBaseY : AlglibFloat;
    TwRowXM1 : AlglibFloat;
    TwRowY : AlglibFloat;
    TmpX : AlglibFloat;
    TmpY : AlglibFloat;
    V : AlglibFloat;
begin
    N := N1*N2;
    V := -2*Pi/N;
    TwBaseXM1 := -2*AP_Sqr(Sin(0.5*V));
    TwBaseY := Sin(V);
    TwRowXM1 := 0;
    TwRowY := 0;
    I:=0;
    while I<=N2-1 do
    begin
        TwXM1 := 0;
        TwY := 0;
        J:=0;
        while J<=N1-1 do
        begin
            Idx := I*N1+J;
            Offs := AOffset+2*Idx;
            X := A[Offs+0];
            Y := A[Offs+1];
            TmpX := X*TwXM1-Y*TwY;
            TmpY := X*TwY+Y*TwXM1;
            A[Offs+0] := X+TmpX;
            A[Offs+1] := Y+TmpY;
            
            //
            // update Tw: Tw(new) = Tw(old)*TwRow
            //
            if J<N1-1 then
            begin
                if J mod FTBaseUpdateTw=0 then
                begin
                    V := -2*Pi*I*(J+1)/N;
                    TwXM1 := -2*AP_Sqr(Sin(0.5*V));
                    TwY := Sin(V);
                end
                else
                begin
                    TmpX := TwRowXM1+TwXM1*TwRowXM1-TwY*TwRowY;
                    TmpY := TwRowY+TwXM1*TwRowY+TwY*TwRowXM1;
                    TwXM1 := TwXM1+TmpX;
                    TwY := TwY+TmpY;
                end;
            end;
            Inc(J);
        end;
        
        //
        // update TwRow: TwRow(new) = TwRow(old)*TwBase
        //
        if I<N2-1 then
        begin
            if J mod FTBaseUpdateTw=0 then
            begin
                V := -2*Pi*(I+1)/N;
                TwRowXM1 := -2*AP_Sqr(Sin(0.5*V));
                TwRowY := Sin(V);
            end
            else
            begin
                TmpX := TwBaseXM1+TwRowXM1*TwBaseXM1-TwRowY*TwBaseY;
                TmpY := TwBaseY+TwRowXM1*TwBaseY+TwRowY*TwBaseXM1;
                TwRowXM1 := TwRowXM1+TmpX;
                TwRowY := TwRowY+TmpY;
            end;
        end;
        Inc(I);
    end;
end;


(*************************************************************************
Linear transpose: transpose complex matrix stored in 1-dimensional array

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure InternalComplexLinTranspose(var A : TReal1DArray;
     M : AlglibInteger;
     N : AlglibInteger;
     AStart : AlglibInteger;
     var Buf : TReal1DArray);
begin
    FFTICLTRec(A, AStart, N, Buf, 0, M, M, N);
    APVMove(@A[0], AStart, AStart+2*M*N-1, @Buf[0], 0, 2*M*N-1);
end;


(*************************************************************************
Linear transpose: transpose real matrix stored in 1-dimensional array

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure InternalRealLinTranspose(var A : TReal1DArray;
     M : AlglibInteger;
     N : AlglibInteger;
     AStart : AlglibInteger;
     var Buf : TReal1DArray);
begin
    FFTIRLTRec(A, AStart, N, Buf, 0, M, M, N);
    APVMove(@A[0], AStart, AStart+M*N-1, @Buf[0], 0, M*N-1);
end;


(*************************************************************************
Recurrent subroutine for a InternalComplexLinTranspose

Write A^T to B, where:
* A is m*n complex matrix stored in array A as pairs of real/image values,
  beginning from AStart position, with AStride stride
* B is n*m complex matrix stored in array B as pairs of real/image values,
  beginning from BStart position, with BStride stride
stride is measured in complex numbers, i.e. in real/image pairs.

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FFTICLTRec(var A : TReal1DArray;
     AStart : AlglibInteger;
     AStride : AlglibInteger;
     var B : TReal1DArray;
     BStart : AlglibInteger;
     BStride : AlglibInteger;
     M : AlglibInteger;
     N : AlglibInteger);
var
    I : AlglibInteger;
    J : AlglibInteger;
    Idx1 : AlglibInteger;
    Idx2 : AlglibInteger;
    M2 : AlglibInteger;
    M1 : AlglibInteger;
    N1 : AlglibInteger;
begin
    if (M=0) or (N=0) then
    begin
        Exit;
    end;
    if Max(M, N)<=8 then
    begin
        M2 := 2*BStride;
        I:=0;
        while I<=M-1 do
        begin
            Idx1 := BStart+2*I;
            Idx2 := AStart+2*I*AStride;
            J:=0;
            while J<=N-1 do
            begin
                B[Idx1+0] := A[Idx2+0];
                B[Idx1+1] := A[Idx2+1];
                Idx1 := Idx1+M2;
                Idx2 := Idx2+2;
                Inc(J);
            end;
            Inc(I);
        end;
        Exit;
    end;
    if N>M then
    begin
        
        //
        // New partition:
        //
        // "A^T -> B" becomes "(A1 A2)^T -> ( B1 )
        //                                  ( B2 )
        //
        N1 := N div 2;
        if (N-N1>=8) and (N1 mod 8<>0) then
        begin
            N1 := N1+(8-N1 mod 8);
        end;
        Assert(N-N1>0);
        FFTICLTRec(A, AStart, AStride, B, BStart, BStride, M, N1);
        FFTICLTRec(A, AStart+2*N1, AStride, B, BStart+2*N1*BStride, BStride, M, N-N1);
    end
    else
    begin
        
        //
        // New partition:
        //
        // "A^T -> B" becomes "( A1 )^T -> ( B1 B2 )
        //                     ( A2 )
        //
        M1 := M div 2;
        if (M-M1>=8) and (M1 mod 8<>0) then
        begin
            M1 := M1+(8-M1 mod 8);
        end;
        Assert(M-M1>0);
        FFTICLTRec(A, AStart, AStride, B, BStart, BStride, M1, N);
        FFTICLTRec(A, AStart+2*M1*AStride, AStride, B, BStart+2*M1, BStride, M-M1, N);
    end;
end;


(*************************************************************************
Recurrent subroutine for a InternalRealLinTranspose


  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FFTIRLTRec(var A : TReal1DArray;
     AStart : AlglibInteger;
     AStride : AlglibInteger;
     var B : TReal1DArray;
     BStart : AlglibInteger;
     BStride : AlglibInteger;
     M : AlglibInteger;
     N : AlglibInteger);
var
    I : AlglibInteger;
    J : AlglibInteger;
    Idx1 : AlglibInteger;
    Idx2 : AlglibInteger;
    M1 : AlglibInteger;
    N1 : AlglibInteger;
begin
    if (M=0) or (N=0) then
    begin
        Exit;
    end;
    if Max(M, N)<=8 then
    begin
        I:=0;
        while I<=M-1 do
        begin
            Idx1 := BStart+I;
            Idx2 := AStart+I*AStride;
            J:=0;
            while J<=N-1 do
            begin
                B[Idx1] := A[Idx2];
                Idx1 := Idx1+BStride;
                Idx2 := Idx2+1;
                Inc(J);
            end;
            Inc(I);
        end;
        Exit;
    end;
    if N>M then
    begin
        
        //
        // New partition:
        //
        // "A^T -> B" becomes "(A1 A2)^T -> ( B1 )
        //                                  ( B2 )
        //
        N1 := N div 2;
        if (N-N1>=8) and (N1 mod 8<>0) then
        begin
            N1 := N1+(8-N1 mod 8);
        end;
        Assert(N-N1>0);
        FFTIRLTRec(A, AStart, AStride, B, BStart, BStride, M, N1);
        FFTIRLTRec(A, AStart+N1, AStride, B, BStart+N1*BStride, BStride, M, N-N1);
    end
    else
    begin
        
        //
        // New partition:
        //
        // "A^T -> B" becomes "( A1 )^T -> ( B1 B2 )
        //                     ( A2 )
        //
        M1 := M div 2;
        if (M-M1>=8) and (M1 mod 8<>0) then
        begin
            M1 := M1+(8-M1 mod 8);
        end;
        Assert(M-M1>0);
        FFTIRLTRec(A, AStart, AStride, B, BStart, BStride, M1, N);
        FFTIRLTRec(A, AStart+M1*AStride, AStride, B, BStart+M1, BStride, M-M1, N);
    end;
end;


(*************************************************************************
recurrent subroutine for FFTFindSmoothRec

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FTBaseFindSmoothRec(N : AlglibInteger;
     Seed : AlglibInteger;
     LeastFactor : AlglibInteger;
     var Best : AlglibInteger);
begin
    Assert(FTBaseMaxSmoothFactor<=5, 'FTBaseFindSmoothRec: internal error!');
    if Seed>=N then
    begin
        Best := Min(Best, Seed);
        Exit;
    end;
    if LeastFactor<=2 then
    begin
        FTBaseFindSmoothRec(N, Seed*2, 2, Best);
    end;
    if LeastFactor<=3 then
    begin
        FTBaseFindSmoothRec(N, Seed*3, 3, Best);
    end;
    if LeastFactor<=5 then
    begin
        FTBaseFindSmoothRec(N, Seed*5, 5, Best);
    end;
end;


(*************************************************************************
Internal subroutine: array resize

  -- ALGLIB --
     Copyright 01.05.2009 by Bochkanov Sergey
*************************************************************************)
procedure FFTArrayResize(var A : TInteger1DArray;
     var ASize : AlglibInteger;
     NewASize : AlglibInteger);
var
    Tmp : TInteger1DArray;
    I : AlglibInteger;
begin
    SetLength(Tmp, ASize);
    I:=0;
    while I<=ASize-1 do
    begin
        Tmp[I] := A[I];
        Inc(I);
    end;
    SetLength(A, NewASize);
    I:=0;
    while I<=ASize-1 do
    begin
        A[I] := Tmp[I];
        Inc(I);
    end;
    ASize := NewASize;
end;


(*************************************************************************
Reference FHT stub
*************************************************************************)
procedure RefFHT(var A : TReal1DArray;
     N : AlglibInteger;
     Offs : AlglibInteger);
var
    Buf : TReal1DArray;
    I : AlglibInteger;
    J : AlglibInteger;
    V : AlglibFloat;
begin
    Assert(N>0, 'RefFHTR1D: incorrect N!');
    SetLength(Buf, N);
    I:=0;
    while I<=N-1 do
    begin
        V := 0;
        J:=0;
        while J<=N-1 do
        begin
            V := V+A[Offs+J]*(Cos(2*Pi*I*J/N)+Sin(2*Pi*I*J/N));
            Inc(J);
        end;
        Buf[I] := V;
        Inc(I);
    end;
    I:=0;
    while I<=N-1 do
    begin
        A[Offs+I] := Buf[I];
        Inc(I);
    end;
end;


end.