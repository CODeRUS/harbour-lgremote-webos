import QtQuick 2.1
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

Image {
    id: image

    property bool themeImage: imageSource.toString().indexOf("image://theme/") == 0

    property bool highlighted
    property color highlightColor: Theme.highlightColor
    property url _highlightSource: highlighted ? (imageSource.toString() + "?" + highlightColor) : imageSource
    property url imageSource

    source: imageSource != "" ? _highlightSource : ""

    fillMode: Image.PreserveAspectFit
    cache: true
    smooth: true

    layer.effect: ShaderEffect {
        id: shaderItem
        property color color: image.highlightColor

        fragmentShader: "
            varying mediump vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D imageSource;
            uniform highp vec4 color;
            void main() {
                highp vec4 pixelColor = texture2D(imageSource, qt_TexCoord0);
                gl_FragColor = vec4(mix(pixelColor.rgb/max(pixelColor.a, 0.00390625), color.rgb/max(color.a, 0.00390625), color.a) * pixelColor.a, pixelColor.a) * qt_Opacity;
            }
        "
    }
    layer.enabled: imageSource != "" && !themeImage && image.highlighted
    layer.samplerName: layer.enabled ? "imageSource" : ""
}
