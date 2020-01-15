package com.tencent.liteav.demo.lvb.camerapush;

import android.graphics.Bitmap;

import com.tencent.liteav.demo.beauty.IBeautyKit;
import com.tencent.rtmp.TXLivePusher;

public class PusherBeautyKit implements IBeautyKit {

    private TXLivePusher mLivePusher;                    // SDK 推流类

    public PusherBeautyKit(TXLivePusher livePusher) {
        mLivePusher = livePusher;
    }

    @Override
    public void setFilter(Bitmap filterImage, int index) {
        if (mLivePusher != null) {
            mLivePusher.setFilter(filterImage);
        }
    }

    @Override
    public void setSpecialRatio(float specialRatio) {
        if (mLivePusher != null) {
            mLivePusher.setSpecialRatio(specialRatio / 10.0f);
        }
    }

    @Override
    public void setGreenScreenFile(String path, boolean isLoop) {
        if (mLivePusher != null) {
            mLivePusher.setGreenScreenFile(path);
        }
    }

    @Override
    public void setBeautyStyle(int beautyStyle) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setBeautyStyle(beautyStyle);
        }
    }

    @Override
    public void setBeautyLevel(int beautyLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setBeautyLevel(beautyLevel);
        }
    }

    @Override
    public void setWhitenessLevel(int whitenessLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setWhitenessLevel(whitenessLevel);
        }
    }

    @Override
    public void setRuddyLevel(int ruddyLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setRuddyLevel(ruddyLevel);
        }
    }

    @Override
    public void setEyeScaleLevel(int eyeScaleLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setEyeScaleLevel(eyeScaleLevel);
        }
    }

    @Override
    public void setFaceSlimLevel(int faceSlimLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setFaceSlimLevel(faceSlimLevel);
        }
    }

    @Override
    public void setFaceVLevel(int faceVLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setFaceVLevel(faceVLevel);
        }
    }

    @Override
    public void setChinLevel(int chinLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setChinLevel(chinLevel);
        }
    }

    @Override
    public void setFaceShortLevel(int faceShortLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setFaceShortLevel(faceShortLevel);
        }
    }

    @Override
    public void setNoseSlimLevel(int noseSlimLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setNoseSlimLevel(noseSlimLevel);
        }
    }

    @Override
    public void setEyeLightenLevel(int eyeLightenLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setEyeLightenLevel(eyeLightenLevel);
        }
    }

    @Override
    public void setToothWhitenLevel(int toothWhitenLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setToothWhitenLevel(toothWhitenLevel);
        }
    }

    @Override
    public void setWrinkleRemoveLevel(int wrinkleRemoveLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setWrinkleRemoveLevel(wrinkleRemoveLevel);
        }
    }

    @Override
    public void setPounchRemoveLevel(int pounchRemoveLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setPounchRemoveLevel(pounchRemoveLevel);
        }
    }

    @Override
    public void setSmileLinesRemoveLevel(int smileLinesRemoveLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setSmileLinesRemoveLevel(smileLinesRemoveLevel);
        }
    }

    @Override
    public void setForeheadLevel(int foreheadLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setForeheadLevel(foreheadLevel);
        }
    }

    @Override
    public void setEyeDistanceLevel(int eyeDistanceLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setEyeDistanceLevel(eyeDistanceLevel);
        }
    }

    @Override
    public void setEyeAngleLevel(int eyeAngleLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setEyeAngleLevel(eyeAngleLevel);
        }
    }

    @Override
    public void setMouthShapeLevel(int mouthShapeLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setMouthShapeLevel(mouthShapeLevel);
        }
    }

    @Override
    public void setNoseWingLevel(int noseWingLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setNoseWingLevel(noseWingLevel);
        }
    }

    @Override
    public void setNosePositionLevel(int nosePositionLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setNosePositionLevel(nosePositionLevel);
        }
    }

    @Override
    public void setLipsThicknessLevel(int lipsThicknessLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setLipsThicknessLevel(lipsThicknessLevel);
        }
    }

    @Override
    public void setFaceBeautyLevel(int faceBeautyLevel) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setFaceBeautyLevel(faceBeautyLevel);
        }
    }

    @Override
    public void setMotionTmpl(String tmplPath) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setMotionTmpl(tmplPath);
        }
    }

    @Override
    public void setMotionMute(boolean motionMute) {
        if (mLivePusher != null) {
            mLivePusher.getBeautyManager().setMotionMute(motionMute);
        }
    }
}
