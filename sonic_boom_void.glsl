// --- VOID THEME COLORS ---
const vec3 C_BG = vec3(0.0, 0.0, 0.0);           // #000000
const vec3 C_TEAL = vec3(0.329, 0.627, 0.573);   // #54a092

// --- CONFIGURATION ---
const float DURATION = 0.20;               
const float MAX_RADIUS = 0.08;             
const float ANIMATION_START_OFFSET = 0.0;        
vec4 COLOR = vec4(C_TEAL, 0.8);
const float CURSOR_WIDTH_CHANGE_THRESHOLD = 0.4; 
const float BLUR = 5.0; // Increased blur for a "glow" effect rather than a sharp circle

float easeOutQuart(float t) {
    return 1.0 - pow(1.0 - t, 4.0);
}

float easeOutPulse(float t) {
    return t * (2.0 - t);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    float widthChange = abs(currentCursor.z - previousCursor.z);
    float isModeChange = step(max(currentCursor.z, previousCursor.z) * CURSOR_WIDTH_CHANGE_THRESHOLD, widthChange);

    float rippleProgress = (iTime - iTimeCursorChange) / DURATION + ANIMATION_START_OFFSET;
    float isAnimating = 1.0 - step(1.0, rippleProgress);
     
    if (isModeChange > 0.0 && isAnimating > 0.0) {
        float easedProgress = easeOutQuart(rippleProgress);
        float fade = 1.0 - easeOutPulse(rippleProgress);
        float dist = distance(vu, centerCC);
        float sdfCircle = dist - (easedProgress * MAX_RADIUS);
        
        float antiAliasSize = normalize(vec2(BLUR, BLUR), 0.0).x;
        float ripple = (1.0 - smoothstep(-antiAliasSize, antiAliasSize, sdfCircle)) * fade;
        
        fragColor = mix(fragColor, COLOR, ripple * COLOR.a);
    }
}
