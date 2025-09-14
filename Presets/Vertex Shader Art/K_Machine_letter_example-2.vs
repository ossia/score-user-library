/*{
  "DESCRIPTION": "K Machine letter example",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/vqBN6kLpxjBHGRvz8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 333,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1494862833032
    }
  }
}*/


//[commercial]

//Another K Machine exposed shader
//See it in action in the K Machine v2 on https://vimeo.com/217012333
//the 'K beginning' comments allows the K Machine to recognize
//and build adapted events controllers
//This shader can be copied in a text file with .glsl extension and
//uploaded to the K Machine.
//For more instructions for K Machine compliance see the doc on
//http://kolargon.com/KMachineV2Doc/KMachineV2Documentation.html
//More about the K Machine v2
//http://kolargones.net/wpkolargon/2017/05/05/k-machine-v-2-0/
//Note the part between 'for vsa' and 'end for vsa' could be skipped
//as the K Machine has it's own relLoopProgress float parameter
//corresponding to the progression in the selected loop

//[/commercial]

//KDrawmode=GL_TRIANGLES
#define parameter0 1.//KParameter0 1.>>8.
#define parameter1 -0.2//KParameter1 -1.>>1.
#define parameter2 -1.//KParameter2 -1.>>1.
#define parameter3 0.//KParameter3 0.>>12.
#define parameter4 2.//KParameter4 0.>>2.
#define parameter5 1.//KParameter5 0.1>>1.5
#define parameter6 0.3//KParameter6 0.>>1.
#define parameter7 0.//KParameter7 0.>>10.

#define HPI 1.570796326795
#define PI 3.1415926535898

#define SYMMETRY_H 0
#define SYMMETRY_V 0
#define COLOR_MODE 0

vec3 rotZ(vec3 _v, float _rad) {
    vec2 f = sin(vec2(_rad, _rad + HPI));
    vec3 r = _v;
    r.x = _v.x * f.x + _v.y * f.y;
    r.y = _v.x * -f.y + _v.y * f.x;
    return r;
}

mat4 uniformScale(float _s) {
    return mat4(
        _s, 0, 0, 0,
        0, _s, 0, 0,
        0, 0, _s, 0,
        0, 0, 0, 1);
}

vec3 getShapeVectorForLetter(float _vertexId, float _startVertexId, float _junctionY, float _secondVertY, float _barWidth, vec2 _pos, float _scale, float _rotation, vec2 _letter[18])
{

    vec4 result = vec4(0., 0.,-1., 1.);

    float localVertexId = _vertexId - _startVertexId;

    if(localVertexId<1.)
    {
        result.xy = _letter[0].xy;
    }
    else

        if(localVertexId<2.)
        {
        result.xy = _letter[1].xy;
        }

        else
        if(localVertexId<3.)
        {
        result.xy = _letter[2].xy;
        }
        else //2nd triangle
        if(localVertexId<4.)
        {
        result.xy = _letter[3].xy;
        }
        else
        if(localVertexId<5.)
        {
        result.xy = _letter[4].xy;
        }
        else
        if(localVertexId<6.)
        {
        result.xy = _letter[5].xy;
        }
        else
        if(localVertexId<7.)//3 eme triangle
        {
        result.xy = _letter[6].xy;
        }
        else
        if(localVertexId<8.)
        {
        result.xy = _letter[7].xy;
        }
        else
        if(localVertexId<9.)
        {
        result.xy = _letter[8].xy;

        }

        else
        if(localVertexId<10.)//4eme triangle
        {
        result.xy = _letter[9].xy;

        }
        else
        if(localVertexId<11.)
        {
        result.xy = _letter[10].xy;

        }

        else
        if(localVertexId<12.)
        {
        result.xy = _letter[11].xy;

        }
        else
        if(localVertexId<13.)
        {
        result.xy = _letter[12].xy;

        }
        else
        if(localVertexId<14.)
        {
        result.xy = _letter[13].xy;

        }
        else
        if(localVertexId<15.)
        {
        result.xy = _letter[14].xy;

        }
        else
        if(localVertexId<16.)
        {
        result.xy = _letter[15].xy;

        }
        else
        if(localVertexId<17.)
        {
        result.xy = _letter[16].xy;

        }
        else
        if(localVertexId<18.)
        {
        result.xy = _letter[17].xy;

        }
    result.xy+=_pos;
    result.xy-=vec2(_barWidth*2.,0.5)+_pos;
    result.xyz =rotZ(result.xyz, _rotation);
    result.xy+=vec2(_barWidth*2.,0.5)+_pos;
    result *= uniformScale(_scale);

    return result.xyz;
}

vec2 getPosFromShapeId(const float _shapeId, const float _selectedShape, const float _relLoopProgress, const float _percentProgress, const float _relLetterTimeProgress, const vec2 _pos)
{
    vec2 finalPos = _pos;

    vec2 additionalPos = vec2(0.,0.);

    float transfoMode = floor(parameter3);

    //additionalPos.x = _relLetterTimeProgress*0.5;
    if(transfoMode<1.)
    {
        if(_selectedShape == _shapeId)
        {
        additionalPos.y = sin(_relLetterTimeProgress*PI)*parameter6*2.;
        finalPos+= additionalPos;
        }
    }
    else
        if(transfoMode<2.)
        {
        additionalPos.y = sin(_relLetterTimeProgress*PI)*parameter6;
        finalPos+= additionalPos;
        }
        else
        if(transfoMode<3.)
        {
        additionalPos = -finalPos;
        additionalPos.x+= parameter6*cos( (_shapeId/8.)*2.*PI );
        additionalPos.y+= parameter6*sin( (_shapeId/8.)*2.*PI );
        finalPos+= additionalPos;
        }
        else
        if(transfoMode<4.)
        {
        additionalPos = -finalPos;
        vec4 m = texture(touch, vec2(0., (0.2+0.2*parameter6/10.)*(_shapeId/8.) ));

        additionalPos.x+= m.x;
        additionalPos.y+= m.y;
        finalPos+= additionalPos;
        }
        else
        if(transfoMode<5.)
        {
        additionalPos.y+= (parameter6/10.)*1.5*cos( _shapeId+(2.*PI *time));
        finalPos+= additionalPos;
        }
        else
        if(transfoMode<6.)
        {
        additionalPos = -finalPos;
        additionalPos.y+= ((1.-_shapeId/8.)-0.5)*1.5;
        additionalPos.x+= (parameter6/10.)*1.5*cos( _shapeId+(2.*PI *time));;
        finalPos+= additionalPos;
        }
        else
        if(transfoMode<7.)
        {
        if(_selectedShape == _shapeId)
        {
        additionalPos.x+= parameter6*cos( _relLetterTimeProgress*2.*PI*(_shapeId/8.) );
        additionalPos.y+= parameter6*sin( _relLetterTimeProgress*2.*PI*(_shapeId/8.) );
        finalPos+= additionalPos;
        }

        }
        else
        if(transfoMode<8.)
        {
        additionalPos = -finalPos;
        if(_selectedShape == _shapeId)
        {
        additionalPos.x+= parameter6*5.*(1.-_relLetterTimeProgress)/2.*cos( 2.*PI*(_shapeId/8.) );
        additionalPos.y+= parameter6*5.*(1.-_relLetterTimeProgress)/2.*sin( 2.*PI*(_shapeId/8.) );

        }
        finalPos+= additionalPos;
        }
        else
        if(transfoMode<9.)
        {
        additionalPos = -finalPos;

        if(mod(_shapeId,2.)<1.)
        {
        additionalPos.x+= parameter6*5.*(1.-_relLetterTimeProgress)/2.*cos( 2.*PI*(_shapeId/8.) );
        additionalPos.y+= parameter6*5.*(1.-_relLetterTimeProgress)/2.*sin( 2.*PI*(_shapeId/8.) );

        }
        finalPos+= additionalPos;
        }
        else

        if(transfoMode<10.)
        {
        //if(_selectedShape == _shapeId)
        {
        vec4 m = texture(sound, vec2((_shapeId/8.-0.25), 0. ));
        additionalPos.y = m.x*parameter6*2.;
        finalPos+= additionalPos;
        }
        }

        else

        if(transfoMode<11.)
        {
        additionalPos = -finalPos;
        additionalPos.x+= sin(_relLoopProgress*PI)*parameter6*cos( (_shapeId/8.)*2.*PI+time );
        additionalPos.y+= sin(_relLoopProgress*PI)*parameter6*sin( (_shapeId/8.)*2.*PI+time);
        finalPos+= additionalPos;
        }

    return finalPos;
}

float getRotationFromShapeId(const float _shapeId, const float _selectedShape, const float _percentProgress, const float _relLetterTimeProgress, const float _rotation)
{
    float finalRot = _rotation;

    float additionalRotation = 0.;

    float transfoMode = floor(parameter3);

    if(transfoMode<1.)
    {

        if(_selectedShape == _shapeId)
        {
        additionalRotation = floor(parameter6+1.)*2.*PI*_relLetterTimeProgress;

        }
    }
    else
        if(transfoMode<1.)
        {

        if(_selectedShape == _shapeId)
        {
        additionalRotation = 2.*2.*PI*_relLetterTimeProgress;

        }
        }

    finalRot+= additionalRotation;

    /*
     float additionalRotation = 0.;

     if(selectedLetterIndex == shapeId)
     {
     additionalRotation = 2.*PI*relLetterTimeProgress;
     }

     rotation = PI/2. + defaultRotationForShapeLetterK+additionalRotation;//0.13;//PI/3.*time*shapeId;
     */

    return finalRot;
}

vec2 getCenterFromShapeId(const float _shapeId, const float _selectedShape, const float _percentProgress, const float _relLetterTimeProgress, const vec2 _center, const vec2 _pos, const float _letterWidth)
{
    vec2 finalCenter = _center;

    /*
     vec2 additionalCenter = vec2(0.,0.);

     if(_selectedShape == _shapeId)
     {
     additionalCenter.x = _relLetterTimeProgress*0.5;
     additionalCenter.y = _relLetterTimeProgress*0.5;
     }

     finalCenter+= additionalCenter;
     */

    return finalCenter;
}

#define elementPerShapeLetterK 18.

#define defaultRotationForShapeLetterK 0.13
#define defaultRotationForShapeLetterM - 0.09
#define defaultRotationForShapeLetterN 0.04
#define defaultRotationForShapeLetterA 0.1
#define defaultRotationForShapeLetterC - 0.05
#define defaultRotationForShapeLetterE - 0.03
#define defaultRotationForShapeLetterH 0.04
#define defaultRotationForShapeLetterI - 0.02

#define shapeNumber 8.
#define numberOfVerticesForWord elementPerShapeLetterK*shapeNumber

void main() {

    vec3 color = vec3(1.);

    float sndFactor = texture(sound, vec2(0.01, 0.)).r;
    float _junctionY = 0.5 +parameter4*sndFactor/10.;

    float _barWidth = 0.2 ;// + parameter4*sndFactor/100.;
    float _secondVertY = 2.4*_barWidth + parameter4*sndFactor/10.;

    float shapeId = 0.;

    vec2 letterK[18];
    letterK[0] = vec2(0.,0.);
    letterK[1] = vec2(0.,1.);
    letterK[2] = vec2(_barWidth,1.);
    letterK[3] = vec2(0.,0.0);
    letterK[4] = vec2(_barWidth,1.);
    letterK[5] = vec2(_barWidth,0.);
    letterK[6] = vec2(_barWidth,_junctionY);
    letterK[7] = vec2((_secondVertY+_barWidth),1.);
    letterK[8] = vec2(_secondVertY,1.);
    letterK[9] = vec2(_barWidth,_junctionY);
    letterK[10] = vec2((_secondVertY+_barWidth),0.);
    letterK[11] = vec2(_secondVertY,0.);
    letterK[12] = vec2(_secondVertY,0.);
    letterK[13] = vec2(_secondVertY,0.);
    letterK[14] = vec2(_secondVertY,0.);
    letterK[15] = vec2(_secondVertY,0.);
    letterK[16] = vec2(_secondVertY,0.);
    letterK[17] = vec2(_secondVertY,0.);

    vec2 letterM[18];
    letterM[0] = vec2(0.,0.);
    letterM[1] = vec2(0.,1.);
    letterM[2] = vec2(_barWidth,1.);
    letterM[3] = vec2(0.,0.0);
    letterM[4] = vec2(_barWidth,1.);
    letterM[5] = vec2(_barWidth,0.);//PROBLEM !!
    letterM[6] = vec2(_barWidth,_junctionY+_barWidth);
    letterM[7] = vec2(_barWidth,1.);
    letterM[8] = vec2(_barWidth*2.,_junctionY);
    letterM[9] = vec2(_barWidth*2.,_junctionY);
    letterM[10] = vec2((_barWidth*3.),1.);
    letterM[11] = vec2(_barWidth*3.,_junctionY+_barWidth);
    letterM[12] = vec2(_barWidth*3.,1.);
    letterM[13] = vec2(_barWidth*4.,1.);
    letterM[14] = vec2(_barWidth*3.,0.);
    letterM[15] = vec2(_barWidth*3.,0.);
    letterM[16] = vec2(_barWidth*4.,1.);
    letterM[17] = vec2(_barWidth*4.,0.);

    vec2 letterN[18];
    letterN[0] = vec2(0.,0.);
    letterN[1] = vec2(0.,1.);
    letterN[2] = vec2(_barWidth,1.);
    letterN[3] = vec2(0.,0.0);
    letterN[4] = vec2(_barWidth,1.);
    letterN[5] = vec2(_barWidth,0.);
    letterN[6] = vec2(_barWidth,_junctionY+_barWidth);
    letterN[7] = vec2(_barWidth,1.);
    letterN[8] = vec2(_barWidth*2.,_junctionY);
    letterN[9] = vec2(_barWidth*2.,1.);
    letterN[10] = vec2(_barWidth*3.,1.);
    letterN[11] = vec2(_barWidth*2.,0.);

    letterN[12] = vec2(_barWidth*2.,0.);
    letterN[13] = vec2(_barWidth*3.,1.);
    letterN[14] = vec2(_barWidth*3.,0.);
    letterN[15] = vec2(_barWidth*3.,0.);

    letterN[16] = vec2(_barWidth*3.,0.);
    letterN[17] = vec2(_barWidth*3.,0.);

    vec2 letterA[18];
    letterA[0] = vec2(0.,0.);
    letterA[1] = vec2(_barWidth,0.);
    letterA[2] = vec2(_barWidth*2.,1.);
    letterA[3] = vec2(_barWidth*4.,0.0);
    letterA[4] = vec2(_barWidth*2.,1.);
    letterA[5] = vec2(_barWidth*3.,0.);
    letterA[6] = vec2(_barWidth,_junctionY-_barWidth/2.);
    letterA[7] = vec2(_barWidth*1.5,_junctionY+_barWidth/2.);
    letterA[8] = vec2(_barWidth*3.,_junctionY);
    letterA[9] = vec2(_barWidth*3.,_junctionY);
    letterA[10] = vec2(_barWidth*3.,_junctionY);
    letterA[11] = vec2(_barWidth*3.,_junctionY);

    letterA[12] = vec2(_barWidth*3.,_junctionY);
    letterA[13] = vec2(_barWidth*3.,_junctionY);
    letterA[14] = vec2(_barWidth*3.,_junctionY);
    letterA[15] = vec2(_barWidth*3.,_junctionY);

    letterA[16] = vec2(_barWidth*3.,_junctionY);
    letterA[17] = vec2(_barWidth*3.,_junctionY);

    vec2 letterE[18];
    letterE[0] = vec2(0.,0.);
    letterE[1] = vec2(0.,1.);
    letterE[2] = vec2(_barWidth,1.);
    letterE[3] = vec2(0.,0.0);
    letterE[4] = vec2(_barWidth,1.);
    letterE[5] = vec2(_barWidth,0.);
    letterE[6] = vec2(_barWidth,_junctionY+_barWidth*1.5);
    letterE[7] = vec2(_barWidth,1.);
    letterE[8] = vec2(_barWidth*3.,1.);
    letterE[9] = vec2(_barWidth,_junctionY-_barWidth*1.5);
    letterE[10] = vec2(_barWidth,0.);
    letterE[11] = vec2(_barWidth*3.,0.);
    letterE[12] = vec2(_barWidth,_junctionY);
    letterE[13] = vec2(_barWidth*2.5,_junctionY+_barWidth/2.);
    letterE[14] = vec2(_barWidth*2.5,_junctionY-_barWidth/2.);
    letterE[15] = vec2(_barWidth*2.5,_junctionY-_barWidth/2.);
    letterE[16] = vec2(_barWidth*2.5,_junctionY-_barWidth/2.);
    letterE[17] = vec2(_barWidth*2.5,_junctionY-_barWidth/2.);

    vec2 letterC[18];
    letterC[0] = vec2(0.,0.);
    letterC[1] = vec2(0.,1.);
    letterC[2] = vec2(_barWidth,1.);
    letterC[3] = vec2(0.,0.0);
    letterC[4] = vec2(_barWidth,1.);
    letterC[5] = vec2(_barWidth,0.);
    letterC[6] = vec2(_barWidth,0.5+_barWidth*1.5);
    letterC[7] = vec2(_barWidth,1.);
    letterC[8] = vec2(_barWidth*3.,1.);
    letterC[9] = vec2(_barWidth,0.);
    letterC[10] = vec2(_barWidth,0.5-_barWidth*1.5);
    letterC[11] = vec2(_barWidth*3.,0.);
    letterC[12] = vec2(_barWidth*3.,0.);
    letterC[13] = vec2(_barWidth*3.,0.);
    letterC[14] = vec2(_barWidth*3.,0.);
    letterC[15] = vec2(_barWidth*3.,0.);
    letterC[16] = vec2(_barWidth*3.,0.);
    letterC[17] = vec2(_barWidth*3.,0.);

    vec2 letterH[18];
    letterH[0] = vec2(0.,0.);
    letterH[1] = vec2(0.,1.);
    letterH[2] = vec2(_barWidth,1.);
    letterH[3] = vec2(0.,0.0);
    letterH[4] = vec2(_barWidth,1.);
    letterH[5] = vec2(_barWidth,0.);
    letterH[6] = vec2(_barWidth,_junctionY-_barWidth/2.);
    letterH[7] = vec2(_barWidth,_junctionY+_barWidth/2.);
    letterH[8] = vec2(_barWidth*2.,_junctionY);
    letterH[9] = vec2(_barWidth*2.,_junctionY);
    letterH[10] = vec2((_barWidth*3.),_junctionY+_barWidth/2.);
    letterH[11] = vec2(_barWidth*3.,_junctionY-_barWidth/2.);
    letterH[12] = vec2(_barWidth*3.,1.);
    letterH[13] = vec2(_barWidth*4.,1.);
    letterH[14] = vec2(_barWidth*3.,0.);
    letterH[15] = vec2(_barWidth*3.,0.);
    letterH[16] = vec2(_barWidth*4.,1.);
    letterH[17] = vec2(_barWidth*4.,0.);

    vec2 letterI[18];
    letterI[0] = vec2(0.,0.);
    letterI[1] = vec2(0.,_junctionY+_barWidth);
    letterI[2] = vec2(_barWidth,_junctionY+_barWidth);
    letterI[3] = vec2(0.,0.0);
    letterI[4] = vec2(_barWidth,_junctionY+_barWidth);
    letterI[5] = vec2(_barWidth,0.);//PROBLEM !!
    letterI[6] = vec2(0.,1.-_barWidth);
    letterI[7] = vec2(0.,1.);
    letterI[8] = vec2(_barWidth,1.-_barWidth);
    letterI[9] = vec2(_barWidth,1.-_barWidth);
    letterI[10] = vec2(0.,1.);
    letterI[11] = vec2(_barWidth,1.);
    letterI[12] = vec2(_barWidth,1.);
    letterI[13] = vec2(_barWidth,1.);
    letterI[14] = vec2(_barWidth,1.);
    letterI[15] = vec2(_barWidth,1.);
    letterI[16] = vec2(_barWidth,1.);
    letterI[17] = vec2(_barWidth,1.);

    float acceptedNumberOfWords = floor(vertexCount/float(numberOfVerticesForWord));
    float maxNumberOfVertices = acceptedNumberOfWords*numberOfVerticesForWord;//

    float finalVertexId = vertexId;//mod(vertexId,numberOfVerticesForWord);//min(maxNumberOfVertices,vertexId);
    //finalVertexId = min(finalVertexId,maxNumberOfVertices);// mod(finalVertexId, numberOfVerticesForWord);

    finalVertexId = min(maxNumberOfVertices,vertexId);

    finalVertexId = mod(finalVertexId,float(numberOfVerticesForWord));

    //float metaShapeId = floor(vertexId/float(256.));//floor(finalVertexId/numberOfVerticesForWord);
    //float relMetaShapeId = metaShapeId/256.;

    float masterScale = parameter5;//parameter6;

    vec3 _v = vec3(0.,0.,0.);

    vec2 letterPos = vec2(0.,0.);

    float marginBetweenLetters = 3.*_barWidth+parameter4*sndFactor/10.;

    float scaleK = 0.4*masterScale;
    float scale = 0.2*masterScale;
    float startPosK = parameter2;
    float startPosM = startPosK + marginBetweenLetters*scaleK;//+(2.*marginBetweenLetters);

    vec2 shapeCenter = vec2(0.,0.5);

    //for vsa

    float loopDurationMs = 4000.;
    float timeProgress = mod(time*1000.,loopDurationMs);
    float relLoopProgress = timeProgress/loopDurationMs;

    //end for vsa

    float finalRelLoopProgress = relLoopProgress;//mod(relLoopProgress,(1./factor));

    float numberOfSubLoops = floor(parameter0);
    float subLoopLength = 1./numberOfSubLoops;
    finalRelLoopProgress = mod(relLoopProgress,subLoopLength)/subLoopLength;

    float letterTimeProgress = mod(finalRelLoopProgress,(1./shapeNumber));
    float relLetterTimeProgress = letterTimeProgress/(1./shapeNumber);

    float selectedLetterIndex = floor(shapeNumber*finalRelLoopProgress);

    /////////////////////////

    float rotation = PI/3.*time*shapeId;

    if(finalVertexId<elementPerShapeLetterK)
    {
        shapeId = 0.;

        rotation = PI/2. + defaultRotationForShapeLetterK;//+additionalRotation;//0.13;//PI/3.*time*shapeId;

        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);

        letterPos.x = startPosK;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress,letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = ((_barWidth*4.)*scaleK)/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, 0.,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scaleK, rotation, letterK);

    }

    else

        if(finalVertexId<2.*elementPerShapeLetterK)
        {
        shapeId = 1.;

        rotation = PI/2. + defaultRotationForShapeLetterM;//+additionalRotation;//- 0.09;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);
        letterPos.x = startPosM;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);
        //float letterWidth = (_barWidth*4.)*scale/2.;
        shapeCenter.x = letterPos.x+(_barWidth*4.)*scale/2.;
        shapeCenter.y = 0.5;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterM);

        }

        else
        if(finalVertexId<3.*elementPerShapeLetterK)
        {
        shapeId = 2.;

        rotation = PI/2. + defaultRotationForShapeLetterA;//+additionalRotation;//0.1;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);

        letterPos.x = startPosM+( (shapeId - 1.)*(_barWidth*4.+marginBetweenLetters))*scale;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = letterPos.x+(_barWidth*4.)*scale/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterA);

        }

        else
        if(finalVertexId<4.*elementPerShapeLetterK)
        {
        shapeId = 3.;

        rotation = PI/2. + defaultRotationForShapeLetterC;//+additionalRotation;//- 0.05;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);

        letterPos.x = 0.;

        letterPos.x = startPosM+( (shapeId - 1.)*(_barWidth*4.+marginBetweenLetters))*scale;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = letterPos.x+(_barWidth*3.)*scale/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterC);

        }

        else
        if(finalVertexId<5.*elementPerShapeLetterK)
        {
        shapeId = 4.;

        rotation = PI/2. + defaultRotationForShapeLetterH;//+additionalRotation;//0.04;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);

        letterPos.x = startPosM+( (shapeId - 1.)*(_barWidth*4.+marginBetweenLetters) - _barWidth)*scale;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = letterPos.x+(_barWidth*4.)*scale/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterH);

        }

        else
        if(finalVertexId<6.*elementPerShapeLetterK)
        {
        shapeId = 5.;

        rotation = PI/2. +defaultRotationForShapeLetterI;//+additionalRotation;//- 0.02;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);

        letterPos.x = startPosM+( (shapeId - 1.)*(_barWidth*4.+marginBetweenLetters) - _barWidth)*scale;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = letterPos.x+(_barWidth*1.)*scale/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterI);

        }

        else
        if(finalVertexId<7.*elementPerShapeLetterK)
        {
        shapeId = 6.;

        rotation = PI/2. + defaultRotationForShapeLetterN;//+additionalRotation;//0.04;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);
        letterPos.x = startPosM+( (shapeId - 1.)*(_barWidth*4.+marginBetweenLetters) - 4.*_barWidth)*scale;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = letterPos.x+(_barWidth*3.)*scale/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);

        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterN);
        }

        else
        if(finalVertexId<8.*elementPerShapeLetterK)
        {
        shapeId = 7.;
        float additionalRotation = 0.;

        rotation = PI/2. +defaultRotationForShapeLetterE;//+additionalRotation;//- 0.03;//PI/3.*time*shapeId;
        rotation = getRotationFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, rotation);

        letterPos.x = startPosM+( (shapeId - 1.)*(_barWidth*4.+marginBetweenLetters) - 5.*_barWidth)*scale;
        letterPos = getPosFromShapeId(shapeId, selectedLetterIndex, finalRelLoopProgress, letterTimeProgress, relLetterTimeProgress, letterPos);

        shapeCenter.x = letterPos.x+(_barWidth*3.)*scale/2.;
        shapeCenter = getCenterFromShapeId(shapeId, selectedLetterIndex, letterTimeProgress, relLetterTimeProgress, shapeCenter, letterPos, 0.);
        _v = getShapeVectorForLetter(finalVertexId, shapeId*elementPerShapeLetterK,_junctionY, _secondVertY, _barWidth, vec2(-shapeCenter.x,-shapeCenter.y), scale, rotation, letterE);

        }

    _v.x +=letterPos.x;
    _v.y +=letterPos.y;

    _v = rotZ(_v,PI/2.+parameter7*time);

    if(vertexId<float(numberOfVerticesForWord))
    {

    }

#if SYMMETRY_V >0
    else
        if(vertexId<float(numberOfVerticesForWord)*2.)
        {
        _v.x = -_v.x;

        }
#endif
#if SYMMETRY_H >0
        else
        if(vertexId<float(numberOfVerticesForWord)*3.)

        {
        _v.y = -_v.y;
        }
#endif

#if SYMMETRY_V >0 && SYMMETRY_H >0
        else
        if(vertexId<float(numberOfVerticesForWord)*4.)
        {
        _v.y = -_v.y;
        _v.x = -_v.x;
        }

#endif

    _v.x*=resolution.y/resolution.x;//

#if COLOR_MODE ==1
    if(mod(shapeId,2.)<1.)
    {
        color = vec3(1.,1.,0.);
    }
    else
    {
        color = vec3(1.,0.,0.);
    }
#endif
#if COLOR_MODE ==2
    if(mod(shapeId,2.)<1.)
    {
        color = vec3(1.,1.,1.);
    }
    else
    {
        color = vec3(0.29,.96,0.89);
    }
#endif

    gl_Position = vec4(_v, 1.);

    v_color = vec4(color, .1);

}

