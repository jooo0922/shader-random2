#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// shader-random1 예제에서 배웠던 랜덤함수들을 다시 사용할거임.
// 각 랜덤함수에 대한 설명은 이전 random1 예제 참고
float rand(float f) {
  return fract(sin(f * 4214.124) * 4214.2457);
}

float rand(vec2 v2) {
  float f = dot(v2, vec2(24.125, 24.658));
  return fract(sin(f * 13.2124) * 75421.4325);
}

// 대각선을 그리는 함수
// 매개변수는 1. 각 픽셀들 좌표값(coord), 2. 대각선 방향을 판단해 줄 boolean값(toggle)
vec3 line(vec2 coord, bool toggle) {
  float y;

  float r = 0.132; // smoothstep() 함수의 1, 2번째 인자값의 간격으로 사용할 값. '그려질 대각선의 두께'라고 봐도 무방함.
  float ret;

  // boolean값인 toggle 값이 true / false 냐에 따라 대각선 방향이 결졍될 ret값을 달리 계산하게 됨.
  if(toggle) {
    // toggle이 true면 원래 방식대로 각 픽셀들의 x좌표값을 넣어줘서 ret값을 계산하도록 함. -> 대각선이 우상단을 향하게 됨.
    y = coord.x;
  } else {
    // toggle이 false면 1 - coord.x 값을 넣어줘서 ret값이 계산되도록 함. -> 대각선이 우하단으로 내리꽂게 됨.
    y = 1. - coord.x;
  }

  ret = smoothstep(y - r, y, coord.y) - smoothstep(y, y + r, coord.y); // 리턴값 (shader-smoothstep의 구간별_리턴값_분포.png 참고)

  // black과 white 사이의 값을 ret 비율에 따라 섞어줌. black은 (1 - ret)만큼, white는 ret 만큼 섞음
  // shader-smoothstep 예제에서는 이거를 공식으로 풀어서 썼었지?
  return mix(vec3(0.), vec3(1.), ret);
}

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들 좌표값 normalize
  coord *= 10.; // 캔버스 좌표계를 10배로 키움. 즉, 0 ~ 1 사이의 좌표값을 0 ~ 10 으로 Mapping 시킴.

  // 대각선의 방향을 결정하는 boolean값을 지난 번 예제에서 배웠던 두번째 랜덤함수로 구함.
  // 즉, floor() 내장함수를 사용하여 각 픽셀들 좌표값의 정수부분만 따로 떼어내서 만든 vec2를 인자로 전달하여
  // 두 번째 랜덤함수를 실행한 뒤, 리턴된 float 랜덤값이 0.5보다 크면 true, 작으면 false를 dir에 할당하도록 한 것.
  // ternary operator(삼항연산자) 를 사용했음.
  // 이 때, 위의 코드에서 캔버스 좌표계를 10배로 키워줬기 때문에,
  // 각 타일영역마다 캔버스 좌표계의 좌표계는 0 ~ 9 사이 정수부분을 가지게 되고,
  // 정수부분이 같은 픽셀들의 경우 같은 dir값을 공유하게 되겠지!
  bool dir = rand(floor(coord)) > 0.5 ? true : false;

  // 캔버스 좌표계를 타일화시킴
  // 왜? 좌표값의 정수부분을 모두 없애버리고 소수부분(fract)만 남겨주면, 0 ~ 10 사이의 좌표값을 사실상 0 ~ 1사이의 좌표값 10번 반복으로 Mapping 시키게 되는 셈이기 때문!
  coord = fract(coord);

  coord.x *= u_resolution.x / u_resolution.y; // 캔버스를 resizing 해도 왜곡이 없도록 좌표값에 해상도비율값 곰해줌.

  vec3 col = line(coord, dir);

  gl_FragColor = vec4(col, 1.);
}

/*
  네 번째 예제의 대각선 타일을 그리는 방법

  shader-smoothstep 예제에서
  smoothstep() 내장함수를 이용해서
  그라데이션이 있는 내장함수를 그리는 방법을 배웠음.

  이 예제에서 사용했던 방법으로 각 타일마다 대각선을 그려줄 것.
*/