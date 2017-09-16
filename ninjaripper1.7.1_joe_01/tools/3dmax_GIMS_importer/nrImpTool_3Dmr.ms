
--enlarge the heap. Prevents "Runtime Error: Out of scripter memory"
(
	local	MultMB = (1024 * 1024),
			HeapAdd = (512 * MultMB),
			HeapAddMin = (16 * MultMB)
	while (
		(HeapAdd >= HeapAddMin) and (
			try (
				HeapSize += HeapAdd
				false
			) catch
				true
		)
	) do
		HeapAdd /= 2
)
		
-- force using all cores except 1st
(
	local	CPUCount = SysInfo.CPUCount
	if CPUCount != 1 then (
		local	BitSet = Bit.Set,
				TargetAffinity = 0
		for CoreID = 2 to CPUCount do
			TargetAffinity = (BitSet TargetAffinity CoreID true)
		SysInfo.ProcessAffinity = TargetAffinity
	)
)

fn StringClear OrigStr = (
	local Str = ""
	for j = 1 to OrigStr.count do (
		local	char = OrigStr[j]
		if char != " " then
			Append Str char
	)
   Str
)

fn CreateMeshName Num = (
	local	Str = "Mesh_"
	Append Str (formattedPrint (Num as Integer) format:"#04u")
	Append Str ".rip"
	Str
)

--Globals additional 
global	f, fname

global g_ImportType = 1       --- Group/Single/List  (0,1,2)
global g_InputSrc   = ""      --- Source Dir/File
global	g_Diff_FileLev = 0,
			g_Bump_FileLev = 2,
			g_Spec_FileLev = 1

global g_ninjarotX = 90
global g_ninjarotY = 0
global g_ninjarotZ = 0
global g_flipUV = 1

global g_scaleUV = 1
global mdlscaler = 100
	
global g_ninjaMovX = 0
global g_ninjaMovY = 0
global g_ninjaMovZ = 0

global g_MirrorX = 1
global g_MirrorY = 1
global g_MirrorZ = 1
global g_flipFaces = 0
global mover1 = 11

global g_moveUVbyU = 0
global g_moveUVbyV = 0

global	g_IsYetiMesh = false,
			g_IsGTAVMesh = false,	--<TODO> remove or implement controls, debug
			g_DoRemoveUnusedBones = true

global g_VertType = 0
global g_FaceType = 0
global g_UVType = 0
global g_WeightType = 0

global g_BoneCount = 200

global g_FlipUV_U = 1
global g_FlipUV_V = 1

fn isNumSeqNR str = ((trimLeft str ".0123456789").count == 0)
fn isNumSeqNRBasicTypes str = ((trimLeft str "0123").count == 0)
fn isNumSeqNRSpecialType str = ((trimLeft str "01234").count == 0)

--utility
global	nrImpTool_3Dmr

if nrImpTool_3Dmr != undefined then
	destroydialog nrImpTool_3Dmr

rollout nrImpTool_3Dmr "Ninja Import Tool" Width:260 Height:507 (
	local	ProcessPostedMessages = (
				try
					Windows.ProcessPostedMessages
				catch
					(DotNETClass "Application").DoEvents
			)
	
	--tweaks
	groupBox texgrp "Texture IDs" pos:[121,375] width:134 height:80
	label lbl6 "Diffuse" pos:[128, 395] width:70 height:15
 	spinner spnDiffLev "" pos:[188, 395] width:45 height:16 range:[0, 7, 0] type:#integer
	label lbl61 "Bump" pos:[128, 415] width:70 height:15
 	spinner spnBumpLev "" pos:[188, 415] width:45 height:16 range:[0, 7, 2] type:#integer
	label lbl62 "Specular" pos:[128, 435] width:70 height:15
 	spinner spnSpecLev "" pos:[188, 435] width:45 height:16 range:[0, 7, 1] type:#integer
	
	checkbox etDoRemoveUnusedBones "Remove unused bones" pos:[121, 457] checked:true
	checkbox etIsYetiMesh "Yeti mesh" pos:[121, 477] checked:false
	
	ProgressBar theProgressBar Pos:[5, 495] Width:250 Height:10
	
	-- Source select
	groupBox grp1 "Source Select" pos:[5,5] width:249 height:113
	radioButtons RadioImport "" pos:[58,27] width:161 height:16 labels:#("Group", "Single", "List File") default:2 columns:3

	label lblInputFile "Input .rip File:" pos:[12,58] width:68 height:17 visible:true
	label lblInputDir "Input Dir:" pos:[12,58] width:68 height:17 visible:false
	label lblInputLst "Input .lst File:" pos:[12,58] width:68 height:17 visible:false
	editText InputSrc "" pos:[84,55] width:129 height:20
	button SelectSrc "..." pos:[220,56] width:26 height:19 toolTip:""
	
	label lbl10 "RIP File Nums" pos:[13,85] width:69 height:18 enabled:false
	editText RipList "" pos:[84,82] width:162 height:20 enabled:false
	--Transform
	groupBox grp4 "Transformations" pos:[5,125] width:109 height:307
		
		-- Scale Section
		label lblscale "Scale" pos:[12,149] width:77 height:15 enabled:true
		edittext etscale "" pos:[41,148] width:65 height:16 enabled:true
		
		-- Rotate Section
		label lblrotateX "Rotate X" pos:[12,181] width:77 height:15 enabled:true
		spinner spnrotateX "" pos:[61,180] width:45 height:16 range:[0,360,g_ninjarotX] scale:90 type:#integer enabled:true
		
		label lblrotateY "Rotate Y" pos:[12,207] width:77 height:15 enabled:true
		spinner spnrotateY "" pos:[61,206] width:45 height:16 range:[0,360,g_ninjarotY] scale:90 type:#integer enabled:true
		
		label lblrotateZ "Rotate Z" pos:[12,233] width:77 height:15 enabled:true
		spinner spnrotateZ "" pos:[61,232] width:45 height:16 range:[0,360,g_ninjarotZ] scale:90 type:#integer enabled:true
		
		-- Move Section
		label lblmoveX "Move X" pos:[12,263] width:77 height:15 enabled:true
		edittext etmoveX "" pos:[52,262] width:54 height:16 enabled:true
		
		label lblmoveY "Move Y" pos:[12,285] width:77 height:15 enabled:true
		edittext etmoveY "" pos:[52,284] width:54 height:16 enabled:true
		
		label lblmoveZ "Move Z" pos:[12,307] width:77 height:15 enabled:true
		edittext etmoveZ "" pos:[52,306] width:54 height:16 enabled:true
		
		-- Flip Faces Section		
		checkbox ffChecker "Flip Faces" pos:[12,334] checked:true
		
		-- Mirror Object Section		
		checkbox MirrorXChecker "Mirror Along X" pos:[12,354] checked:false
		checkbox MirrorYChecker "Mirror Along Y" pos:[12,374] checked:false
		checkbox MirrorZChecker "Mirror Along Z" pos:[12,394] checked:false
	
	-- UV Parameters
	groupBox paramUV_grp "UV Parameters" pos:[121,125] width:134 height:120

		-- UV Scale Section
		label lblscaleUV "Scale UV" pos:[128,149] width:77 height:15 enabled:true
		edittext etscaleUV "" pos:[182,148] width:65 height:16 enabled:true
		
		-- UV Move Section
		label lblmoveUVbyU "MoveUV U" pos:[128,171] width:77 height:15 enabled:true
		edittext etmoveUVbyU "" pos:[182,170] width:65 height:16 enabled:true
		
		label lblmoveUVbyV "MoveUV V" pos:[128,193] width:77 height:15 enabled:true
		edittext etmoveUVbyV "" pos:[182,192] width:65 height:16 enabled:true
		
		-- Flip UV Section		
		checkbox chkFlipUV_U "Flip U" pos:[138,218] checked:false
		checkbox chkFlipUV_V "Flip V" pos:[192,218] checked:true
		
		-- Vert, Face, UV, Weight types Section
		label lblVertType "Vertex Type" pos:[128,263+mover1] width:77 height:15 enabled:true
		label lblVertTypeNum "0..3" pos:[205,263+mover1] width:77 height:15 enabled:false
		edittext etVertType "" pos:[223,262+mover1] width:24 height:16 enabled:true
		
		label lblFaceType "Face Type" pos:[128,285+mover1] width:77 height:15 enabled:true
		label lblFaceTypeNum "0..3" pos:[205,285+mover1] width:77 height:15 enabled:false
		edittext etFaceType "" pos:[223,284+mover1] width:24 height:16 enabled:true
		
		label lblUVType "UV Type" pos:[128,307+mover1] width:77 height:15 enabled:true
		label lblUVTypeNum "0..3" pos:[205,307+mover1] width:77 height:15 enabled:false
		edittext etUVType "" pos:[223,306+mover1] width:24 height:16 enabled:true
		
		label lblWeightType "Weight Type" pos:[128,329+mover1] width:77 height:15 enabled:true
		label lblWeightTypeNum "0..4" pos:[205,329+mover1] width:77 height:15 enabled:false
		edittext etWeightType "" pos:[223,328+mover1] width:24 height:16 enabled:true
		
		-- Parameters
		groupBox param_grp "Mesh Sub-Types" pos:[121,250] width:134 height:120	
				
		-- UV Scale Section
-- 		label lblBoneCount "Bones" pos:[128,400] width:77 height:15 enabled:true
-- 		edittext etBoneCount "" pos:[182,399] width:65 height:16 enabled:true

		-- Bone Counter Group
-- 		groupBox bonecount_grp "Bone Counter" pos:[121,375] width:134 height:57
				
	-- Import button
	button BtnImport "IMPORT" pos:[5,439] width:109 height:52	
	
	on RadioImport changed state do
	(
		if RadioImport.state == 1 then (
			g_ImportType  = 0
			lbl10.enabled = true
			RipList.enabled = true
			lblInputFile.visible = false
			lblInputDir.visible = true
			lblInputLst.visible = false
			)
		else if RadioImport.state == 2 then (
			g_ImportType = 1
			lbl10.enabled = false
			RipList.enabled = false
			lblInputFile.visible = true
			lblInputDir.visible = false
			lblInputLst.visible = false
			)
		else if RadioImport.state == 3 then (
			g_ImportType = 2
			lbl10.enabled = false
			RipList.enabled = false
			lblInputFile.visible = false
			lblInputDir.visible = false
			lblInputLst.visible = true
			)
	)
	
	on SelectSrc pressed  do (
		case RadioImport.state of (
			1: (	---Group
				g_InputSrc   = getSavePath caption:"Choose directory with .rip files" initialDir:"$scripts"
				if g_InputSrc != undefined do (
					g_InputSrc = g_InputSrc + "\\"
					InputSrc.text = g_InputSrc
				)
			)
			2: (   ---Single
				g_InputSrc = getOpenFileName \ 
								caption:"Ninja Ripper File Select" \
								types:"Ninja Ripper File(*.rip)|*.rip" \
								historyCategory:"Ninja Ripper"
				if g_InputSrc != undefined do
					InputSrc.text = g_InputSrc
			)
			3: ( ---List file
				g_InputSrc = getOpenFileName \ 
								caption:"Ninja Ripper List File Select" \
								types:"Ninja Ripper List File(*.lst)|*.lst" \
								historyCategory:"Ninja Ripper"
				if g_InputSrc != undefined do
					InputSrc.text = g_InputSrc
			)
		)
	)
	
	--on spnscale changed val do g_ninjaScale = val
	on spnrotateX changed val do g_ninjarotX = val
	on spnrotateY changed val do g_ninjarotY = val	
	on spnrotateZ changed val do g_ninjarotZ = val
		
	on etscale changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etscale.text = "100"))
	on etmoveX changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etmoveX.text = "0"))
	on etmoveY changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etmoveY.text = "0"))
	on etmoveZ changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etmoveZ.text = "0"))
	on etscaleUV changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etscaleUV.text = "1"))
	on etmoveUVbyU changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etmoveUVbyU.text = "0"))
	on etmoveUVbyV changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
		etmoveUVbyV.text = "0"))
	on etVertType changed txt do (if not isNumSeqNRBasicTypes txt do (messagebox "You can write only numbers from 0 to 3!"
		etVertType.text = "0"))
	on etFaceType changed txt do (if not isNumSeqNRBasicTypes txt do (messagebox "You can write only numbers from 0 to 3!"
		etFaceType.text = "0"))
	on etUVType changed txt do (if not isNumSeqNRBasicTypes txt do (messagebox "You can write only numbers from 0 to 3!"
		etUVType.text = "0"))
	on etWeightType changed txt do (if not isNumSeqNRSpecialType txt do (messagebox "You can write only numbers from 0 to 4!"
		etWeightType.text = "0"))
-- 	on etBoneCount changed txt do (if not isNumSeqNR txt do (messagebox "You can write only numbers!"
-- 		etBoneCount.text = "175"))
		
	on etscale entered txt do mdlscaler = etscale.text as float
	on etmoveX entered txt do g_ninjaMovX = etmoveX.text as float
	on etmoveY entered txt do g_ninjaMovY = etmoveY.text as float
	on etmoveZ entered txt do g_ninjaMovZ = etmoveZ.text as float

	on etscaleUV entered txt do g_scaleUV = etscaleUV.text as float

	on etmoveUVbyU entered txt do g_moveUVbyU = etmoveUVbyU.text as float
	on etmoveUVbyV entered txt do g_moveUVbyV = etmoveUVbyV.text as float

	on etDoRemoveUnusedBones Changed state do g_DoRemoveUnusedBones = state
	on etIsYetiMesh Changed state do g_IsYetiMesh = state
		
	on etVertType entered txt do g_VertType = etVertType.text as integer
	on etFaceType entered txt do g_FaceType = etFaceType.text as integer
	on etUVType entered txt do g_UVType = etUVType.text as integer
	on etWeightType entered txt do g_WeightType = etWeightType.text as integer

-- 	on etBoneCount entered txt do g_BoneCount = etBoneCount.text as integer

	on nrImpTool_3Dmr Close do (
		ResumeEditing()
		EnableSceneRedraw()
		if f != undefined then
			FClose f
	)
	
	on nrImpTool_3Dmr Open do (
		ResumeEditing()
		EnableSceneRedraw()
		
		etscale.text = "100"
		
		etmoveX.text = "0"
		etmoveY.text = "0"
		etmoveZ.text = "0"
		
		etscaleUV.text = "1"
		etmoveUVbyU.text = "0"
		etmoveUVbyV.text = "0"
		
		etIsYetiMesh.state = false
		
		etVertType.text = "0"
		etFaceType.text = "0"
		etUVType.text = "0"
		etWeightType.text = "0"
		
-- 		etBoneCount.text = "175"
	)
	
	on ffChecker changed FFstate do
		(
			if ffChecker.checked == true then (g_flipFaces = 1)
			else (g_flipFaces = 0)
		)
		
	on MirrorXChecker changed MirXState do
		(
			if MirrorXChecker.checked == false then (g_MirrorX = 1)
			else (g_MirrorX = -1)
		)	
	on MirrorYChecker changed MirYState do
		(
			if MirrorYChecker.checked == false then (g_MirrorY = 1)
			else (g_MirrorY = -1)
		)	
	on MirrorZChecker changed MirZState do
		(
			if MirrorZChecker.checked == false then (g_MirrorZ = 1)
			else (g_MirrorZ = -1)
		)	
		
	on chkFlipUV_U changed FlipUV_U_State do
		(
			if chkFlipUV_U.checked == false then (g_FlipUV_U = 1)
			else (g_FlipUV_U = -1)
		)
		
	on chkFlipUV_V changed FlipUV_V_State do
		(
			if chkFlipUV_V.checked == false then (g_FlipUV_V = -1)
			else (g_FlipUV_V = 1)
		)	
		
	fn ImportRip g_InputSrc = (
		fname = g_InputSrc
		f = (fopen fname "rb")
		FileIn "nrImp_3Dmr\\nrImpScript_3Dmr.ms" Quiet:true
		GC()
		GC()
	)
	
	fn UIProgressUpdate Val = (
		theProgressBar.Value = Val
		ProcessPostedMessages()
	)
	fn UIProgressEnd = (
		theProgressBar.Value = 0
	)
	
	on BtnImport pressed do (
		if f != undefined then
			FClose f
		local	scrSubPath = "\\nrImp_3Dmr\\nrImpScript_3Dmr.ms",
				scrPath = (scriptspath + scrSubPath)
		if (DoesFileExist scrPath) then (
			g_Diff_FileLev = (spnDiffLev.value as Integer)
			g_Bump_FileLev = (spnBumpLev.value as Integer)
			g_Spec_FileLev = (spnSpecLev.value as Integer)
			case g_ImportType of (
				0: (	--group
					if InputSrc.text.count > 0 then (
						if RipList.text.count > 0 then ( 
							RipDir = (getFilenamePath InputSrc.text)
						
							tokens = (filterString RipList.text ",")
							FilteredTokens = #()
							
							---Remove token whitespaces
							for i = 1 to tokens.count do (
								local Str = StringClear tokens[i]
								append FilteredTokens ( Str as String )
							)
							
							---Import loop. Split tokens with "-"
							local	Files = #()
							for i = 1 to FilteredTokens.count do (
								RangeTokens = (filterString FilteredTokens[i] "-")
								if RangeTokens.count == 1 then (  --Single element
									RipDir1 = RipDir
									ss = (CreateMeshName RangeTokens[1])
									RipDir1 = (RipDir1 + ss)
									if (DoesFileExist RipDir1) then
										Append Files RipDir1
								)
								else(  ---Range element
									r0 = RangeTokens[1] as Integer
									r1 = RangeTokens[2] as Integer
									if r0 < r1 then (
										for j = r0 to r1 do(
											RipDir1 = RipDir
											ss = (CreateMeshName j)
											RipDir1 = (RipDir1 + ss)
											if (DoesFileExist RipDir1) then
												Append Files RipDir1
										)
									)
									else
										MessageBox ("Incorrect range: " + r0 as String + " to " + r1 as String)
								)
							)
							local	FileCount = Files.Count,
									FileStep = (100.0 / FileCount)
							for i = 1 to FileCount do (
								UIProgressUpdate (FileStep * i)
								ImportRip Files[i]
							)
							UIProgressEnd()
						)
						else
							MessageBox "Type file list"
					)
					else
						MessageBox "Select dir"
				)
				1: (	--single
					if
						g_InputSrc != undefined and
						(DoesFileExist g_InputSrc)
					then (
						UIProgressUpdate 100
						ImportRip g_InputSrc
						UIProgressEnd()
					) else
						MessageBox "Select RIP file"
				)
				2: (	--list
					MessageBox "Import from list file not realized"
				)
			)
		) else
			messagebox ("Can't find the file: \"<3D MAX root>\\scripts" + scrSubPath + "\"") Title:"Can't find script"
	)--end button press
)

createDialog nrImpTool_3Dmr pos:[250, 250] style:#(#style_sysmenu,#style_toolwindow)
