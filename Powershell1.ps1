$hhmm="201810111111"
$path="C:\clearing\files"
$ldate="20181011"


Write-Host "Time:$hhmm"
Write-Host ""
Write-Host ""
Write-Host ""

IF (Test-Path "$path"){

    Write-Host "Folder Exist"
    Write-Host "cd $path"
    cd "$path"
}else{

  Write-Host "$path does not exist!! Exiting..."
  exit 999
}


IF ((Test-Path "DC20181011.txt") -AND (Test-Path "RC20181011.txt")){

  Write-Host "REJECT AND ENCODING FILES EXIST"

}else{
   Write-Host "REJECT AND ENCODING FILES DO NOT  EXIST !! Exiting..."
  exit 999
}


#If ((Test-Path "ENC_TT1.txt") -AND (Test-Path "ENC_TT2.txt"))


$deparr=@()
Get-Content .\DC20181011.txt | Select-Object -Skip 1 | ForEach {
		if($_.trim() -ne ""){
      $dep_accnum = $_.Split("\*")[4]
		  $dep_accnum = $dep_accnum.trim()
		  $dep_chqno = $_.Split("\*")[7]
		  $dep_chqno = $dep_chqno.trim()
		  $dep_bnkcode = $_.Split("\*")[8]
		  $dep_bnkcode = $dep_bnkcode.trim()
		  $dep_chqamount = $_.Split("\*")[6]
		  $dep_chqamount = $dep_chqamount.trim()
		  $dep_arecode = $_.Split("\*")[11]
		  $dep_arecode = $dep_arecode.trim()
#		   Write-Host "$dep_accnum,$dep_chqno, $dep_chqamount, $dep_arecode,$dep_bnkcode"
		   $deparr += "$dep_accnum*$dep_chqno*$dep_chqamount*$dep_arecode*$dep_bnkcode"
		}
 }

$rejarr=@()
 Get-Content .\RC20181011.txt | Select-Object -Skip 1 | ForEach {
		  if($_.trim() -ne ""){
		  $rej_bnkcode = $_.Split("\*")[1]
		  $rej_bnkcode = $rej_bnkcode.trim()
      $rej_accnum = $_.Split("\*")[3]
		  $rej_accnum = $rej_accnum.trim()
		  $rej_chqno = $_.Split("\*")[6]
		  $rej_chqno = $rej_chqno.trim()
		  $rej_chqamount = $_.Split("\*")[5]
		  $rej_chqamount = $rej_chqamount.trim()
		  $rej_arecode = $_.Split("\*")[9]
		  $rej_arecode = $rej_arecode.trim()
#!		   Write-Host "$rej_accnum,$rej_chqno,$rej_chqamount,$rej_arecode,$rej_bnkcode"
		   $rejarr += "$rej_accnum*$rej_chqno*$rej_chqamount*$rej_arecode*$rej_bnkcode"
	}
 }

Write-Host "Printing All Encoding REcords...."
Write-Host ""
Write-Host ""
Write-Host ""

if(Test-Path "EncodingAll.txt"){
   Write-Host "Before dumping EncodingAll.txt will be truncated..."
   Clear-Content EncodingAll.txt
}
Write-Host "All encoding Will be written to the file EncodingAll.txt"

$encarr=@()
#Get-Content .\ENC_*.txt | Select-Object -Skip 2 | ForEach {

Get-Content .\ENC_*.txt  | Select-String -n -Pattern "Serial|----------\|" | ForEach{
		if($_.Line.trim() -ne ""){
		  $enc_chqno = $_.Line.Split("\|")[1]
		  $enc_chqno = $enc_chqno.trim()
		  $enc_chqamount = $_.Line.Split("\|")[2]
		  $enc_chqamount = $enc_chqamount.trim()
		  $enc_bnkcode = $_.Line.Split("\|")[3]
		  $enc_bnkcode = $enc_bnkcode.trim()
          $enc_areacode = $_.Line.Split("\|")[4]
		  $enc_areacode = $enc_areacode.trim()

#!		    Write-Host "$enc_chqno,$enc_chqamount,$enc_bnkcode,$enc_areacode"
           "$enc_chqno*$enc_chqamount*$enc_bnkcode*$enc_areacode" | Out-File -Append EncodingAll.txt -Encoding UTF8
		    $encarr += "$enc_chqno*$enc_chqamount*$enc_bnkcode*$enc_areacode"
  }
 }

Write-Host "============================Clearing All Content=================================="
Write-Host ""
Write-Host ""

Write-Host "All MATCH UNMATCH RECORDS  WILL BE CLEARED BEFORE DUMPING THE NEW... "

IF (Test-Path All.txt){
  Clear-Content All.txt
  Write-Host "All.txt truncated..."
}else{
    Write-Host "All.txt does not exist... Skipping..."
}

Write-Host ""
Write-Host ""
Write-Host ""

 ForEach($rejline in $rejarr){
		    $rej_chqno = $rejline.Split('\*')[1]
			$rej_chqno = [int]$rej_chqno
			$rej_chqamount = $rejline.Split('\*')[2]
			$rej_chqamount = [double]$rej_chqamount
		    $rej_arecode = $rejline.Split('\*')[3]
			$rej_bnkcode = $rejline.Split('\*')[4]
			$rejcnt = 0
			#Write-Host "REJ:$rej_chqno,$rej_chqamount"
			ForEach($encline in $encarr){
				$enc_chqno = $encline.Split('\*')[0]
				$enc_chqno = [int]$enc_chqno
				$enc_chqamount = $encline.Split('\*')[1]
				$enc_chqamount = [double]$enc_chqamount
				$enc_bnkcode = $encline.Split('\*')[2]
                $enc_areacode = $encline.Split('\*')[3]
				#Write-Host "ENC:$enc_chqno,$enc_chqamount"
				if (($enc_chqno -eq $rej_chqno) -AND ($enc_chqamount -eq $rej_chqamount)){
#!					Write-Host "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,MATCH"
                    "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,MATCH" | Out-File All.txt -Append -Encoding UTF8
 #                   "$encline"  | Out-File MatchedENC.txt  -Append -Encoding UTF8
					$rejcnt = 1
				}	
		}
		
		if ($rejcnt -eq 0){
#!		    Write-Host "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,UNMATCH"	
           "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,UNMATCH" | Out-File All.txt -Append -Encoding UTF8


		}
		
	}



ForEach($depline in $deparr){
		    $dep_chqno = $depline.Split('\*')[1]
			$dep_chqno = [int]$dep_chqno
			$dep_chqamount = $depline.Split('\*')[2]
			$dep_chqamount = [double]$dep_chqamount
		    $dep_arecode = $depline.Split('\*')[3]
			$dep_bnkcode = $depline.Split('\*')[4]
			$depcnt = 0
			#Write-Host "REJ:$rej_chqno,$rej_chqamount"
			ForEach($encline in $encarr){
				$enc_chqno = $encline.Split('\*')[0]
				$enc_chqno = [int]$enc_chqno
				$enc_chqamount = $encline.Split('\*')[1]
				$enc_chqamount = [double]$enc_chqamount
				$enc_bnkcode = $encline.Split('\*')[2]
                $enc_areacode = $encline.Split('\*')[3]

				#Write-Host "ENC:$enc_chqno,$enc_chqamount"
				if (($enc_chqno -eq $dep_chqno) -AND ($enc_chqamount -eq $dep_chqamount)){
#!					Write-Host "$dep_chqno,$dep_chqamount,$dep_bnkcode,$dep_arecode,DEPOSIT,MATCH"
                    "$dep_chqno,$dep_chqamount,$dep_bnkcode,$dep_arecode,DEPOSIT,MATCH" | Out-File All.txt -Append -Encoding UTF8
#                   "$encline"  | Out-File MatchedENC.txt -Append -Encoding UTF8
					$depcnt = 1
				}	
		}
		
		if ($depcnt -eq 0){
#!		  Write-Host "$dep_chqno,$dep_chqamount,$dep_bnkcode,$dep_arecode,DEPOSIT,UNMATCH"
          "$dep_chqno,$dep_chqamount,$dep_bnkcode,$dep_arecode,DEPOSIT,UNMATCH" | Out-File All.txt -Append -Encoding UTF8
		}
		
	}

#############################################################################################################################################
##################################################################################################################################
#$rejarr += "$rej_accnum*$rej_chqno*$rej_chqamount*$rej_arecode*$rej_bnkcode"
#$deparr += "$dep_accnum*$dep_chqno*$dep_chqamount*$dep_arecode*$dep_bnkcode"
#$encarr += "$enc_chqno*$enc_chqamount*$enc_bnkcode*$enc_areacode"
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "Next thing comparing Encoding records with reject and Deposit records...."
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""

ForEach($encline in $encarr){
		    $enc_chqno = $encline.Split('\*')[0]
			$enc_chqno = [int]$enc_chqno
			$enc_chqamount = $encline.Split('\*')[1]
			$enc_chqamount = [double]$enc_chqamount
			$enc_bnkcode = $encline.Split('\*')[2]
		    $enc_arecode = $encline.Split('\*')[3]
			$enccnt = 0
			#Write-Host "REJ:$rej_chqno,$rej_chqamount"
			ForEach($rejline in $rejarr){
				$rej_chqno = $rejline.Split('\*')[1]
				$rej_chqno = [int]$rej_chqno
				$rej_chqamount = $rejline.Split('\*')[2]
				$rej_chqamount = [double]$rej_chqamount
				$rej_areacode = $rejline.Split('\*')[3]
				$rej_bnkcode = $rejline.Split('\*')[4]
				#Write-Host "ENC:$enc_chqno,$enc_chqamount"
				if (($enc_chqno -eq $rej_chqno) -AND ($enc_chqamount -eq $rej_chqamount)){
#!					Write-Host "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,MATCH"
#                    "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,MATCH" | Out-File All.txt -Append -Encoding UTF8
#                    "$encline"  | Out-File MatchedENC.txt  -Append -Encoding UTF8
					  $enccnt = 1
				}	
		}		
		
			ForEach($depline in $deparr){
				$dep_chqno = $depline.Split('\*')[1]
				$dep_chqno = [int]$dep_chqno
				$dep_chqamount = $depline.Split('\*')[2]
				$dep_chqamount = [double]$dep_chqamount
				$dep_areacode = $depline.Split('\*')[3]
				$dep_bnkcode = $depline.Split('\*')[4]
				#Write-Host "ENC:$enc_chqno,$enc_chqamount"
				if (($enc_chqno -eq $dep_chqno) -AND ($enc_chqamount -eq $dep_chqamount)){
#!					Write-Host "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,MATCH"
#                    "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,MATCH" | Out-File All.txt -Append -Encoding UTF8
#                    "$encline"  | Out-File MatchedENC.txt  -Append -Encoding UTF8
					  $enccnt = 2
				}	
		}				
		
		if ($enccnt -eq 0){
#!		    Write-Host "$rej_chqno,$rej_chqamount,$rej_bnkcode,$rej_arecode,REJECT,UNMATCH"	
           "$enc_chqno,$enc_chqamount,$enc_bnkcode,$enc_arecode,ENCODING,UNMATCH" | Out-File All.txt -Append -Encoding UTF8


		}
}

############################################################################################################################
Write-Host ""
Write-Host ""
Write-Host "cd testpath"
$testpath="C:\RCS"
cd testpath

If (Test-Path "$testpath\sys\RC20181011.txt" ){

  Write-Host "REject file Exist"...

$areas=@()
$hed_chk=@()

$header = (Get-Content "$testpath\sys\RC20181011.txt" -First 1).Replace('*',',')


Get-Content "$testpath\sys\RC20181011.txt" | Select-Object -Skip 1 |
foreach {
	$area=$_.Split('\*')[9]
	$area = $area.trim()
	if($hed_chk -notcontains $area)
	{
		$hed_chk += $area
        Write-Host "Clearing Content of $testpath\$area\AREA.$area.csv"
        if (Test-Path "$testpath\$area\AREA.$area.csv"){
          Clear-Content "$testpath\$area\AREA.$area.csv"
          Write-Host "OLD file exist will be cleared..."
        }
		$header | Out-File -Append "$testpath\$area\AREA.$area.csv" -Encoding UTF8
	}
	
!	$_ | Out-File -Append "$testpath\$area\AREA.$area.csv" -Encoding UTF8
    $_ -replace '\*',',' | Out-File -Append "$testpath\$area\AREA.$area.csv" -Encoding UTF8
	
}

}else{

  Write-Host "REject file does not Exist"...
}

	
	
	
