Attribute VB_Name = "Base"
'  This macro collection lets you organize your tasks and schedules
'  for you with the evidence based design (EBS) approach by Joel Spolsky.
'
'  Copyright (C) 2019  Christian Weihsbach
'  This program is free software; you can redistribute it and/or modify
'  it under the terms of the GNU General Public License as published by
'  the Free Software Foundation; either version 3 of the License, or
'  (at your option) any later version.
'  This program is distributed in the hope that it will be useful,
'  but WITHOUT ANY WARRANTY; without even the implied warranty of
'  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'  GNU General Public License for more details.
'  You should have received a copy of the GNU General Public License
'  along with this program; if not, write to the Free Software Foundation,
'  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
'
'  Christian Weihsbach, weihsbach.c@gmail.com

Option Explicit

'This module contains 'base'code which deals with extended data structure functionalities

'To compare upper and lower case texts
Option Compare Text

Enum SortDir
    ceDescending = -1
    ceAscending = 1
End Enum


Enum ComparisonTypes
    ceStringComp = 0
    ceEqual = 1
    ceDoubleLess = 2
    ceDoubleBigger = 3
    ceRegex = 4
End Enum


Public Function QuickSort(ByRef vArray As Variant, direction As SortDir, Optional inLow As Long = -1, Optional inHi As Long = -1, _
    Optional ByRef associate As Variant, _
    Optional ByRef associate2 As Variant, _
    Optional ByRef associate3 As Variant)
    
    'This function sorts an numeric array in ascending or descending order.
    'If specified an associate array with equal length will be sorted alike
    '
    'Input args:
    '  vArray: Numeric array to sort
    '  direction:  Ascending or descending direction (enum)
    '  inLow:      Starting index for pivot partitioning. Leave empty when calling the method
    '  inHi:       Ending index for pivot partitioning. Leave empty when calling the method
    '  associate1: Array which will be sorted alike with the vArray. This array can also be non-numeric
    '
    'Output args:
    '  None. vArray and associate array are called by ref and returned via passed args
    'Set the standard limits if no limits are specified
    
    If Not Base.IsArrayAllocated(vArray) Then Exit Function
    
    If IsMissing(inLow) Or inLow = -1 Then
        'Set the starting index for pivoting
        inLow = LBound(vArray)
    End If
    
    If IsMissing(inHi) Or inHi = -1 Then
        'Set the ending index for pivoting
        inHi = UBound(vArray)
    End If
    
    'https://im-coder.com/vba-array-sortierfunktion.html
    Dim pivot   As Variant
    Dim tmpSwap As Variant
  
    Dim tmpAssociateSwap As Variant
  
    Dim tmpLow  As Long
    Dim tmpHi   As Long

    tmpLow = inLow
    tmpHi = inHi

    pivot = vArray((inLow + inHi) \ 2)
    
    'Cycle through the pivoted subgroup of elements and swap
    While (tmpLow <= tmpHi)
        Select Case direction
        
        Case SortDir.ceAscending
            While (vArray(tmpLow) < pivot And tmpLow < inHi)
                tmpLow = tmpLow + 1
            Wend
            While (pivot < vArray(tmpHi) And tmpHi > inLow)
                tmpHi = tmpHi - 1
            Wend
                
        Case SortDir.ceDescending
            While (vArray(tmpLow) > pivot And tmpLow < inHi)
                tmpLow = tmpLow + 1
            Wend
            
            While (pivot > vArray(tmpHi) And tmpHi > inLow)
                tmpHi = tmpHi - 1
            Wend
        End Select
            
        If (tmpLow <= tmpHi) Then
            'Do the swap with the value array
            tmpSwap = vArray(tmpLow)
            vArray(tmpLow) = vArray(tmpHi)
            vArray(tmpHi) = tmpSwap
       
            If Not IsMissing(associate) Then
                'Do the swap for the associate array
                tmpAssociateSwap = associate(tmpLow)
                associate(tmpLow) = associate(tmpHi)
                associate(tmpHi) = tmpAssociateSwap
            End If
            
            If Not IsMissing(associate2) Then
                'Do the swap for the associate array
                tmpAssociateSwap = associate2(tmpLow)
                associate2(tmpLow) = associate2(tmpHi)
                associate2(tmpHi) = tmpAssociateSwap
            End If
            
            If Not IsMissing(associate3) Then
                'Do the swap for the associate array
                tmpAssociateSwap = associate3(tmpLow)
                associate3(tmpLow) = associate3(tmpHi)
                associate3(tmpHi) = tmpAssociateSwap
            End If
            tmpLow = tmpLow + 1
            tmpHi = tmpHi - 1
        End If
    Wend
    
    'Recursively call a sub array to sort
    If (inLow < tmpHi) Then QuickSort vArray, direction, inLow, tmpHi, associate
    If (tmpLow < inHi) Then QuickSort vArray, direction, tmpLow, inHi, associate
End Function



Function FindAll(ByVal rng As Range, ByVal propertyVal As Variant, Optional property As String = "Value", _
    Optional compType As ComparisonTypes = ComparisonTypes.ceStringComp) As Range
    'Find a cell in a given range which matches a given value. By default a text comparison of the cell is performed.
    'This function also works for hidden cells
    
    'Input args:
    '  rng:           The range in which searching is performed
    '  propertyVal:    The value of the property one wants to find ('Value'property is default)
    '  compType:       The type of comparison one wants to use (<, >, etc.)
    '
    'Output args:
    '  FindAll:        Range of cells matching the criteria (subset of rng)

    
    'Init output
    Set FindAll = Nothing
    
    'Check args
    If rng Is Nothing Or StrComp(propertyVal, "") = 0 Then
        Exit Function
    End If
    
    Dim cell As Range
    Dim result As Range
    
    Dim compMatch As Boolean
    
    'Set a flag for the first loop iteration to init the value for union-function
    Dim firstFlag As Boolean
    firstFlag = True
        
    For Each cell In rng
        'Cycle through the range and find all matching cells.
        If Not cell Is Nothing Then
            Dim cellVal As Variant
            
            'Retrieve the property. By default the 'Value'property will be returned.
            cellVal = CallByName(cell, property, VbGet)
            
            If Not IsError(cellVal) Then
                'Perform the comparison
                compMatch = False
                Select Case compType
                    Case ComparisonTypes.ceRegex
                        Dim regex As New RegExp
                        regex.Pattern = propertyVal
                        compMatch = (regex.Test(cellVal))
                    Case ComparisonTypes.ceStringComp
                        compMatch = (StrComp(cellVal, propertyVal) = 0)
                    Case ComparisonTypes.ceEqual
                        compMatch = (cellVal = propertyVal)
                    Case ComparisonTypes.ceDoubleLess
                        compMatch = (CDbl(cellVal) < CDbl(propertyVal))
                    Case ComparisonTypes.ceDoubleBigger
                        compMatch = (CDbl(cellVal) > CDbl(propertyVal))
                End Select
                
                If compMatch Then
                    'Criteria matched - cell found
                    If firstFlag Then
                        'Set the output to the found cell as initial value for the first hit.
                        Set result = cell
                        firstFlag = False
                    Else
                        'Combine the previously found cells to a common range
                        Set result = Base.UnionN(result, cell)
                    End If
                End If
            End If
        End If
    Next cell
    Set FindAll = result
    
    'Debug info
    'Debug.Print result.Address
End Function



Function CollectionToArray(collect As Collection) As Variant
    'Source: https://stackoverflow.com/questions/48153398/converting-vba-collection-to-array
        
    'Convert a collection of strings to a variant array
    'This function also works for hidden cells
    '
    'Input args:
    '  collection:           The collection
    '
    'Output args:
    '  CollectionToArray:    The variant array
    
    'Init output
    Dim arr() As Variant
    CollectionToArray = arr
    
    'Check args
    If collect.Count = 0 Then
        Exit Function
    End If
    
    'Perform conversion
    ReDim arr(0 To collect.Count - 1)
    Dim idx As Integer
    For idx = 0 To collect.Count - 1
        arr(idx) = collect.item(idx + 1)
    Next
    
    CollectionToArray = arr
End Function



Function GetUniqueStrings(stringCollection As Collection) As Collection
    'This function takes a collection of strings and returns a collection with all unique strings.
    'E.g.: {sheep, sheep, dog, cat} becomes {sheep, dog, cat}.
    'A collection is used since the have a dictionary-like data storage option (store val and key)
    '
    'Input args:
    '  stringCollection:   Collection containing strings
    '
    'Output args:
    '  FindAll:        Range of cells matching the criteria (subset of rng)
    
    Dim uniqueCollection As New Collection
    Set GetUniqueStrings = uniqueCollection
    
    If stringCollection Is Nothing Or stringCollection.Count = 0 Then
        Exit Function
    End If
    
    Dim str As Variant
    
    'Defer errors to make collection not complain when key already exists. Mechanism to detect duplicate vals
    On Error Resume Next
    For Each str In stringCollection
        If str = vbNullString Then
            GoTo l4rNextIteration
        End If
        Call uniqueCollection.Add(str, CStr(str))
l4rNextIteration:
    Next str
    
    Set GetUniqueStrings = uniqueCollection
End Function



Function Log10(x As Double) As Double
    Log10 = Log(x) / Log(10#)
End Function



Function Difference(minuend As Range, subtrahend As Range) As Range
    'This function calcs the difference of input ranges
    '
    'Input args:
    '  minuend:        Master range
    '  subtrahend:     Range which contents are removed from 'minuend'
    '
    'Output args:
    '  Difference:     Subset range of cells of minuend
    
    'Init args
    Set Difference = minuend

    'Check args
    If subtrahend Is Nothing Then
        Exit Function
    End If
    
    'Iteratively remove shared cells of the two passed ranges.
    Dim diminishedMinuend As Range
    
    Dim firstValue As Boolean
    firstValue = True
    
    Dim cell As Range
    For Each cell In minuend
        
        'Debug info
        'Debug.Print "cell: " + cell.Address
        'Debug.Print "subtrahend: " + subtrahend.Address
        
        Dim isIntersecting As Boolean
        isIntersecting = (Not Intersect(cell, subtrahend) Is Nothing)
        
        If Not isIntersecting Then
            If firstValue Then
                Set diminishedMinuend = cell
                firstValue = False
            Else
                Set diminishedMinuend = Union(diminishedMinuend, cell)
            End If
        End If
    Next cell
    
    Set Difference = diminishedMinuend
End Function



Function CalcOnArray(f As String, arr As Variant, Optional additionalArg As Variant) As Variant()

    'Runs a function f on every item of an array.
    'f's signature has to be:
    '  f(argIn As Variant, Optional additionalArg As Variant) As Variant
    '
    'The additionalArg can also be an array. If it has the same length as the passed array arr the function is executed element-wise
    '
    'Input args:
    '  f:              Module and function name e.g. PlanningUtils.DoThisAndThat which is applied on every array element
    '  arr:            Array the function is run on
    '  additionalArg:  Argument which is passed to the function f
    '
    'Output args:
    '  CalcOnArray:    The array which contains calculated data
    
    Dim item As Variant
    Dim retArr() As Variant
    ReDim retArr(UBound(arr))
    
    Dim arrIdx As Long
    
    For arrIdx = 0 To UBound(arr)
        Dim argIn As Variant
        Dim argOut As Variant
        
        argIn = arr(arrIdx)
        If IsMissing(additionalArg) Then
            'Calc without additionalArg
            argOut = Application.run(f, argIn)
        Else
            If IsArray(additionalArg) Then
                'Calculate element-wise with both arrays
                If UBound(additionalArg) = UBound(arr) Then
                    'Calc element-wise
                    argOut = Application.run(f, argIn, additionalArg(arrIdx))
                Else
                    'Calc with first element of additional arg
                    argOut = Application.run(f, argIn, additionalArg(0))
                End If
            Else
                'Calc with additional arg (no array type, additionalArg is constant in every cycle)
                argOut = Application.run(f, argIn, additionalArg)
            End If
        End If
        retArr(arrIdx) = argOut
    Next arrIdx
    CalcOnArray = retArr
End Function



Function CalcAddition(summand1 As Double, summand2 As Double) As Double

    'Add-function which works with the 'CalcOnArray'FP (functional programming) mechanism
    '
    'Input args:
    '  summand1:       Val which is added
    '  summand2:       Val which is added
    '
    'Output args:
    '  CalcAddition:   The result
    
    CalcAddition = summand1 + summand2
End Function



Function CalcSubstraction(minuend As Double, subtrahend As Double) As Double

    'Substraction-function which works with the 'CalcOnArray'FP (functional programming) mechanism
    '
    'Input args:
    '  minuend:            Base value
    '  subtrahend:         Value which is substracted from 'minuend'
    '
    'Output args:
    '  CalcSubstraction:   The result
    
    CalcSubstraction = minuend - subtrahend
End Function



Public Function IsArrayAllocated(arr As Variant) As Boolean
    'Source: http://www.cpearson.com/excel/vbaarrays.htm
    
    'Returns TRUE if the array is allocated (either a static array or a dynamic array that has been
    'sized with Redim) or FALSE if the array is not allocated (a dynamic that has not yet
    'been sized with Redim, or a dynamic array that has been Erased). Static arrays are always
    'allocated.
    '
    'The VBA IsArray function indicates whether a variable is an array, but it does not
    'distinguish between allocated and unallocated arrays. It will return TRUE for both
    'allocated and unallocated arrays. This function tests whether the array has actually
    'been allocated.
    '
    'Input args:
    '  arr:                The array which is tested
    '
    'Output args:
    '  IsArrayAllocated:   True/False

    Dim N As Long
    On Error Resume Next
    
    'if Arr is not an array, return FALSE and get out.
    If IsArray(arr) = False Then
        IsArrayAllocated = False
        Exit Function
    End If
    
    'Attempt to get the UBound of the array. If the array has not been allocated,
    'an error will occur. Test Err.Number to see if an error occurred.
    N = UBound(arr, 1)
    If (Err.Number = 0) Then
    
        'Under some circumstances, if an array
        'is not allocated, Err.Number will be
        '0. To acccomodate this case, we test
        'whether LBound <= Ubound. If this
        'is True, the array is allocated. Otherwise,
        'the array is not allocated.
    
        If LBound(arr) <= UBound(arr) Then
            'No error. array has been allocated.
            IsArrayAllocated = True
        Else
            IsArrayAllocated = False
        End If
    Else
        'Error. unallocated array
        IsArrayAllocated = False
    End If
End Function



Function Max(val1 As Variant, Optional val2 As Double) As Double
    'Returns the maximum value of two values or of a passed array
    '
    'Input args:
    '  val1:   Array or double. If array only val1 arg is used
    '
    'Output args:
    '  Max:    The maximum value
    
    'Init output
    Max = 0
    
    'Check args
    If IsArray(val1) And Not Base.IsArrayAllocated(val1) Then Exit Function
    
    If IsArray(val1) Then
        Dim arrVal As Variant
        For Each arrVal In val1
            If arrVal > Max Then Max = CDbl(arrVal)
        Next arrVal
    ElseIf CDbl(val1) > val2 Then
        Max = CDbl(val1)
    Else
        Max = val2
    End If
End Function



Function Min(val1 As Variant, Optional val2 As Double) As Double
    'Returns the minimum value of two values or of a passed array
    '
    'Input args:
    '  val1:   Array or double. If array only val1 arg is used
    '
    'Output args:
    '  Min:    The minimum value
    
    'Init output
    Min = 0
    
    'Check args
    If IsArray(val1) And Not Base.IsArrayAllocated(val1) Then Exit Function
    
    If IsArray(val1) Then
        Dim arrVal As Variant
        For Each arrVal In val1
            If arrVal < Min Then Min = CDbl(arrVal)
        Next arrVal
    ElseIf val1 < val2 Then
        Min = CDbl(val1)
    Else
        Min = val2
    End If
End Function



Function UnionN(first As Range, second As Range) As Range
    'Returns the union of two ranges and checks for input args being nothing
    '
    'Input args:
    '  first:  First range one wants to union
    '  second: Second range one wants to union
    '
    'Output args:
    '  UnionN: The union
    
    If first Is Nothing And Not second Is Nothing Then
        Set UnionN = second
    ElseIf second Is Nothing And Not first Is Nothing Then
        Set UnionN = first
    ElseIf first Is Nothing And second Is Nothing Then
        Set UnionN = Nothing
    Else
        Set UnionN = Union(first, second)
    End If
End Function



Function IntersectN(first As Range, second As Range) As Range
    'Returns the intersection of two ranges and checks for input args being nothing
    '
    'Input args:
    '  first:  First range one wants to intersect
    '  second: Second range one wants to intersect
    '
    'Output args:
    '  IntersectN: The intersection
    
    If first Is Nothing Or second Is Nothing Then
        Set IntersectN = Nothing
    Else
        Set IntersectN = Intersect(first, second)
    End If
End Function



Function GetArrayDimension(arr As Variant) As Long
    'Returns the dimension of an array 'perpendicular'to Ubound(arr)
    '
    'Input args:
    '  arr:                The array
    '
    'Output args:
    '  GetArrayDimension:  The 'perpendicular'dimension
    
    'Try to fetch Ubound of all array dimensions as long as there is no error
    On Error GoTo Err
    Dim idx As Long
    Dim tmp As Long
    idx = 0
    While True
        idx = idx + 1
        tmp = UBound(arr, idx)
    Wend
Err:
    GetArrayDimension = idx - 1
End Function
