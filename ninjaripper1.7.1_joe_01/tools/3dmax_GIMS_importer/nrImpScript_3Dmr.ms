/*TODO
guess bone position and direction mode
optimize:
	fn lookup
	arrays
import:
	colors
	normals
*/

fn ReadHalfFloat fstream = (
	hf = (readshort fstream)
	sign = (bit.get hf 0x10)
	exponent = ((bit.shift (bit.and hf 0x7C00) -10) - 0x10)
	fraction = (bit.and hf 0x03FF)
	exponentF = (exponent + 0x7F)
	if sign then
		outputAsFloat = (bit.or (bit.or (bit.shift fraction 13) (bit.shift exponentF 23)) 80000000L)	--80000000L = (bit.shift 1 31)
	else
		outputAsFloat = (bit.or (bit.shift fraction 13) (bit.shift exponentF 23))
	((bit.intasfloat outputasfloat) * 2)
)

fn readFixedString bstream fixedLen = (
	local str = ""
	for i = 1 to fixedLen do
		Append str (bit.intAsChar (ReadByte bstream #unsigned))
	str
)

global	ReservedBoneIDs = #{}
ReservedBoneIDs.Count = g_BoneCount

fn EnsureBoneCreated globalID = (
	local	boneName = (globalID as string),
			newBone = (getNodeByName boneName)
	if newBone == undefined then (
		local	tfm = (Matrix3 1)
		newBone = (bonesys.createbone tfm.Pos (tfm.Pos + 0.01 * (normalize tfm.row1)) (normalize tfm.row3))
		newBone.name = boneName
		newBone.width = 0.01
		newBone.height = 0.01
		newBone.transform = tfm
		newBone.setBoneEnable false 0
		newBone.wirecolor = yellow
		newbone.showlinks = true
		newBone.pos.controller = (TCB_position())
		newBone.rotation.controller = (TCB_rotation())
	) else
		ReservedBoneIDs[globalID] = true
	newBone
)

struct weight_data (
	boneids,
	weights
)

(
	DisableSceneRedraw()
	SuspendEditing()
	local	c_FaceType,
			c_WeightType
	if g_IsYetiMesh then (
		c_FaceType = 0
		c_WeightType = 1
	) else (
		c_FaceType = g_FaceType
		c_WeightType = g_WeightType
	)

	local	boneNodes = #()
	for i = g_BoneCount to 1 by -1 do
		boneNodes[i] = (EnsureBoneCreated i)

	local	vertArray = #(),	
			faceArray = #(),	
			UV_array = #(),	
			Weight_array = #(),	
			UvPosArray = #(),
			WeightPosArray = #(),
			WPosArray = #(),
			PositionSizeArray = #(),
			ColorPosArray = #(),
			NormalPosArray = #(),
			UvTypeArray = #(),	
			WeightTypeArray = #(),
			TextureFiles = #(),
			Unk1,
			FaceCount,
			VertCount,
			VertSize,
			TexCount,
			Null,
			SecCount,
			HaveWeights = false,
			HaveBoneIDs = false,
			HaveUVs = false,
			pUvPosArray = 0
			pWeightPosArray = 0
			pWPosArray = 0
			pPositionSizeArray = 0
			pColorPosArray = 0
			pNormalPosArray = 0
		
	try (
		local	Magic = (ReadLong f),
				Version = (ReadLong f)

		FaceCount = (ReadLong f)
		VertCount = (ReadLong f)
		VertSize = (ReadLong f)
		TexCount = (ReadLong f)
		Null = (ReadLong f)
		SecCount = (ReadLong f)

		vertArray.Count = VertCount
		faceArray.Count = FaceCount
		UV_array.Count = VertCount
		Weight_array.Count = VertCount
		TextureFiles.Count = TexCount
		
		UvPosArray.Count = SecCount
		WeightPosArray.Count = SecCount
		WPosArray.Count = SecCount
		PositionSizeArray.Count = SecCount
		ColorPosArray.Count = SecCount
		NormalPosArray.Count = SecCount

		for i = 1 to SecCount do (
			local	SecInfo = ((ReadString f) as Name)
			case SecInfo of (
				#POSITION: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					FSeek f Size #seek_cur
					pPositionSizeArray += 1
					PositionSizeArray[pPositionSizeArray] = (
						if g_IsYetiMesh then
							Size
						else
							Offset
					)
				)
				#TANGENT: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					FSeek f Size #seek_cur
				)
				#COLOR: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					FSeek f Size #seek_cur
					pColorPosArray += 1
					ColorPosArray[pColorPosArray] = Offset
				)
				#BINORMAL: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					FSeek f Size #seek_cur
				)
				#NORMAL: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					FSeek f Size #seek_cur
					pNormalPosArray += 1
					NormalPosArray[pNormalPosArray] = Offset
				)
				#BLENDWEIGHT: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					WeightTypeArray.Count = ValueCount
					for i = 1 to ValueCount do
						WeightTypeArray[i] = (ReadLong f)
					pWPosArray += 1
					WPosArray[pWPosArray] = Offset
					HaveWeights = true
				)
				#TEXCOORD: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					UvTypeArray.Count = ValueCount
					for i = 1 to ValueCount do
						UvTypeArray[i] = (ReadLong f)
					HaveUVs = true
					pUvPosArray += 1
					UvPosArray[pUvPosArray] = Offset
				)
				#BLENDINDICES: (
					local	ID = (ReadLong f),
							Offset = (ReadLong f),
							Size = (ReadLong f),
							ValueCount = (ReadLong f)
					FSeek f Size #seek_cur
					pWeightPosArray += 1
					WeightPosArray[pWeightPosArray] = Offset
					HaveBoneIDs = true
				)
-- 				POSITION
-- 				BLENDWEIGHT 
-- 				BLENDINDICIES
-- 				NORMAL
-- 				PSIZE
-- 				TEXCOORD
-- 				TANGENT
-- 				BINORMAL
-- 				TESSFACTOR
-- 				POSITIONT
-- 				COLOR
-- 				FOG
-- 				DEPTH
-- 				SAMPLE
			)
		)

		UvPosArray.Count = pUvPosArray
		WeightPosArray.Count = pWeightPosArray
		WPosArray.Count = pWPosArray
		PositionSizeArray.Count = pPositionSizeArray
		ColorPosArray.Count = pColorPosArray
		NormalPosArray.Count = pNormalPosArray
		
		for i = 1 to TexCount do
			TextureFiles[i] = (readstring f)

		local	FnFaceReader = (
					case c_FaceType of (
						0:
							ReadLong
						1:
							ReadShort
						2:
							ReadFloat
						3:
							ReadHalfFloat
					)
				)

		for i = 1 to FaceCount do (
			local	fa = ((FnFaceReader f #unsigned) + 1),
					fb = ((FnFaceReader f #unsigned) + 1),
					fc = ((FnFaceReader f #unsigned) + 1)
			faceArray[i] = [fa, fb, fc]
		)

		local	VertStart = (FTell f)

		if g_IsYetiMesh then (
			for i = 1 to VertCount do (
				local	getPos = ((FTell f) + VertSize),
						vx = ReadShort f
				FSeek f 2 #seek_cur
				local	vy = ReadShort f
				FSeek f 2 #seek_cur
				local	vz = ReadShort f
				FSeek f 2 #seek_cur
				local	vw = ReadShort f
				FSeek f getPos #seek_set
				vertArray[i] = (([vx, vy, vz] * vw) / 6553500)
			)
		) else (
			local	FnVertReader = (
						case g_VertType of (
							0:
								ReadFloat
							1:
								ReadHalfFloat
							2:
								ReadLong
							3:
								ReadShort
						)
					)
			for i = 1 to VertCount do (
				local	getPos = ((FTell f) + VertSize)
				FSeek f (PositionSizeArray[1]) #seek_cur
				local	vx = (FnVertReader f),
						vy = (FnVertReader f),
						vz = (FnVertReader f)
				FSeek f getPos #seek_set
				vertArray[i] = ([vx, vy, vz] * mdlscaler)
			)
		)

		if
			HaveWeights and \
			HaveBoneIDs
		then (
			FSeek f VertStart #seek_set
			local	FnWeightReader = (
						case c_WeightType of (
							0:
								ReadFloat
							1:
								ReadLong
							2:
								ReadShort
							3:
								ReadHalfFloat
							4:
								ReadLong
						)
					)
			if c_WeightType == 4 then (
				for i = 1 to VertCount do (
					local	Pos = (FTell f),
							getPos = (Pos + VertSize)
					FSeek f WeightPosArray[1] #seek_cur
					local	bone3 = ((ReadLong f) + 1),
							bone1 = ((ReadLong f) + 1),
							bone2 = ((ReadLong f) + 1),
							bone4 = ((ReadLong f) + 1)
					FSeek f (Pos + WPosArray[1]) #seek_set
					local	weight1 = (FnWeightReader f),
							weight2 = (FnWeightReader f),
							weight3 = (FnWeightReader f),
							weight4 = (FnWeightReader f),
							boneids = #(),
							weights = #(),
							maxweight = 0,
							isWeight1Valid = (weight1 != 0),	--<TODO> compare floats properly
							isWeight2Valid = (weight2 != 0),	--<TODO> compare floats properly
							isWeight3Valid = (weight3 != 0),	--<TODO> compare floats properly
							isWeight4Valid = (weight4 != 0),	--<TODO> compare floats properly
							haveVertWeights = false
					if isWeight1Valid then (
						maxweight += weight1
						haveVertWeights = true
					)
					if isWeight2Valid then (
						maxweight += weight2
						haveVertWeights = true
					)
					if isWeight3Valid then (
						maxweight += weight3
						haveVertWeights = true
					)
					if isWeight4Valid then (
						maxweight += weight4
						haveVertWeights = true
					)
					if haveVertWeights then (
						if isWeight1Valid then (
							Append boneids bone1
							Append weights (weight1 as float)
						)
						if isWeight2Valid then (
							Append boneids bone2
							Append weights (weight2 as float)
						)
						if isWeight3Valid then (
							Append boneids bone3
							Append weights (weight3 as float)
						)
						if isWeight4Valid then (
							Append boneids bone4
							Append weights (weight4 as float)
						)
					)
					FSeek f getPos #seek_set
					Weight_array[i] = (weight_data boneids:boneids weights:weights)
				)
			) else (
				for i = 1 to VertCount do (
					local	Pos = (FTell f),
							getPos = (Pos + VertSize)
					FSeek f WeightPosArray[1] #seek_cur
					local	bone1 = ((ReadLong f) + 1),
							bone2 = ((ReadLong f) + 1),
							bone3 = ((ReadLong f) + 1),
							bone4 = ((ReadLong f) + 1)
					FSeek f (Pos + WPosArray[1]) #seek_set
					local	weight1 = (FnWeightReader f),
							weight2 = (FnWeightReader f),
							weight3 = (FnWeightReader f),
							weight4 = (FnWeightReader f)
					/*DEBUG
					local	bone1, bone2, bone3, bone4,
							weight1, weight2, weight3, weight4
					if g_IsGTAVMesh then (
						FSeek f WeightPosArray[1] #seek_cur
						bone1 = ((ReadLong f) + 1)
						bone2 = ((ReadLong f) + 1)
						bone3 = ((ReadLong f) + 1)
						bone4 = ((ReadLong f) + 1)
						FSeek f (Pos + WPosArray[1]) #seek_set
						weight1 = (FnWeightReader f)
						weight2 = (FnWeightReader f)
						weight3 = (FnWeightReader f)
						weight4 = (FnWeightReader f)
					) else (
						FSeek f WeightPosArray[1] #seek_cur
						bone1 = ((ReadLong f) + 1)
						bone2 = ((ReadLong f) + 1)
						bone3 = ((ReadLong f) + 1)
						bone4 = ((ReadLong f) + 1)
						FSeek f (Pos + WPosArray[1]) #seek_set
						weight1 = (FnWeightReader f)
						weight2 = (FnWeightReader f)
						weight3 = (FnWeightReader f)
						weight4 = (FnWeightReader f)
					)
					*/
					local	boneids = #(),
							weights = #(),
							maxweight = 0,
							isWeight1Valid = ((Abs weight1) > 0.000001),
							isWeight2Valid = ((Abs weight2) > 0.000001),
							isWeight3Valid = ((Abs weight3) > 0.000001),
							isWeight4Valid = ((Abs weight4) > 0.000001),
							haveVertWeights = false
					if isWeight1Valid then (
						maxweight += weight1
						haveVertWeights = true
					)
					if isWeight2Valid then (
						maxweight += weight2
						haveVertWeights = true
					)
					if isWeight3Valid then (
						maxweight += weight3
						haveVertWeights = true
					)
					if isWeight4Valid then (
						maxweight += weight4
						haveVertWeights = true
					)
					if haveVertWeights then (
						if isWeight1Valid then (
							Append boneids bone1
							Append weights (weight1 as float)
						)
						if isWeight2Valid then (
							Append boneids bone2
							Append weights (weight2 as float)
						)
						if isWeight3Valid then (
							Append boneids bone3
							Append weights (weight3 as float)
						)
						if isWeight4Valid then (
							Append boneids bone4
							Append weights (weight4 as float)
						)
					)
					FSeek f getPos #seek_set
					Weight_array[i] = (weight_data boneids:boneids weights:weights)
					--Format "weight_data\t\tBoneIDs:%\t\tWeights:%\n" (local	str = "#("; for v in boneids do (Append str " 0x"; Append str (FormattedPrint v Format:"02X")); Append str ")"; str) weights	--<TODO> remove, debug
				)
			)
		)

		if HaveUVs then (
			FSeek f VertStart #seek_set
			if g_IsYetiMesh then (
				for i = 1 to VertCount do (
					local	getPos = ((FTell f) + VertSize)
					FSeek f (UvPosArray[1]) #seek_cur
					local	tu = (ReadLong f),
							tv = (-(ReadLong f))
					fseek f getPos #seek_set
					UV_array[i] = ([(tu + g_moveUVbyU) * g_FlipUV_U, (tv + g_moveUVbyV) * g_FlipUV_V, 0] / 1024 * g_scaleUV)
				)
			) else (
				local	FnUVReader = (
							case g_UVType of (
								0:
									ReadFloat
								1:
									ReadShort
								2:
									ReadLong
								3:
									ReadHalfFloat
							)
						)
				for i = 1 to VertCount do (
					local	getPos = ((FTell f) + VertSize)
					FSeek f (UvPosArray[1]) #seek_cur
					local	tu = (FnUVReader f),
							tv = (-(FnUVReader f))
					FSeek f getPos #seek_set
					UV_array[i] = ([(tu + g_moveUVbyU) * g_FlipUV_U, (tv + g_moveUVbyV) * g_FlipUV_V, 0] * g_scaleUV)
				)
			)
		)
		--create the mesh
		local	MeshPath = (GetFileNamePath fname),
				DiffFileName = TextureFiles[1 + g_Diff_FileLev],
				BumpFileName = TextureFiles[1 + g_Bump_FileLev],
				SpecFileName = TextureFiles[1 + g_Spec_FileLev]
		if DiffFileName == undefined then
			DiffFileName = "setka.png"
		local	BumpMap = (
					if BumpFileName != undefined then
						(Normal_Bump Normal_Map:(BitmapTexture Name:BumpFileName FileName:(MeshPath + BumpFileName)))
				),
				SpecularLevelMap = (
					if SpecFileName != undefined then
						(RGB_Tint Map1:(BitmapTexture Name:SpecFileName FileName:(MeshPath + SpecFileName)) Red:White Green:Black Blue:Black)
				)
				thenewmaterial = (
					Standard \
					Name:DiffFileName \
					ShowInViewport:true \
					DiffuseMap: (BitmapTexture Name:DiffFileName FileName:(MeshPath + DiffFileName)) \
					BumpMap:BumpMap \
					BumpMapAmount:100 \
					SpecularLevelMap:SpecularLevelMap
				)
		local	cmnName = (GetFilenameFile fname),
				msh = (mesh vertices:vertArray faces:faceArray)
		msh.Name = cmnName
		msh.DisplayByLayer = false
		msh.BackfaceCull = false
		msh.WireColor = (Color (random 0 255) (random 0 255) (random 0 255))
		msh.Material = thenewmaterial
		if HaveUVs then (
			msh.numTVerts = UV_array.count
			BuildTVFaces msh
			for j = 1 to UV_array.count do
				setTVert msh j UV_array[j]
			for j = 1 to faceArray.count do
				setTVFace msh j faceArray[j]
		)
		--<TODO> apply colors and normals
		--Flip Faces
		if g_flipFaces == 1 then
			try (meshop.flipNormals msh #{g_flipFaces..msh.numfaces}) catch()
		msh.transform = (prescale msh.transform [g_MirrorX, g_MirrorY, g_MirrorZ])
		resetxform msh
		--Aplly mesh movement
		msh.pos = [g_ninjaMovX, g_ninjaMovY, g_ninjaMovZ]
		--Aplly mesh rotation
		local	currentMatrix = msh.transform
		preRotate currentMatrix (eulertoquat (eulerAngles g_ninjarotX g_ninjarotY g_ninjarotZ))
		msh.transform = currentMatrix
		resetxform msh
		maxOps.CollapseNode msh off
		--skin
		ResumeEditing()
		EnableSceneRedraw()
		if
			HaveWeights and \
			HaveBoneIDs
		then (
			select msh
			max modify mode
			local	skinMod = (skin())
			addModifier msh skinMod
			for i = 1 to boneNodes.count do
				skinOps.addBone skinMod boneNodes[i] 0
			Update msh
			modPanel.setCurrentObject skinMod
			try (
				for i = 1 to vertArray.count do (
					local	w = Weight_array[i],
							boneids = w.boneids
					for boneID in boneids do (
						if boneID > 1024 then
							throw "Wrong bone id " boneID
						if boneID > g_BoneCount then (
							for bid = boneID to (g_BoneCount + 1) by -1 do (
								local	newBone = (EnsureBoneCreated bid)
								boneNodes[bid] = newBone
								skinOps.addBone skinMod newBone 0
							)
							g_BoneCount = boneID
						)
						ReservedBoneIDs[boneID] = true
					)
					skinOps.ReplaceVertexWeights skinMod i boneids w.weights
				)
				if g_DoRemoveUnusedBones then (
					local	unusedBoneIDs = (#{1..g_BoneCount} - ReservedBoneIDs)
					for bid in unusedBoneIDs do
						Delete boneNodes[bid]
				)
			) catch (
				MessageBox ("Wrong skinning data!\n\n" + (GetCurrentException()))	Title:"Ninja Ripper mesh import"
				Delete boneNodes
			)
		)
		FClose f
	) catch (
		FClose f
		throw
	)
)
