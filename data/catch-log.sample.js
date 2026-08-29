/*
 * サンプルデータ（画面の見え方確認用の作り物）。
 * data/catch-log.js が空のときだけ自動で読み込まれ、画面上に「サンプル表示中」と出ます。
 * 実データが1件でも入ると、このファイルは使われません。
 */
window.CATCH_LOG_SAMPLE = [
  { id:"s1", date:"2026-08-24", area:"sagami", spot:"小田原沖", spotType:"沖-釣り船", method:"オフショアジギング",
    species:["ワラサ","イナダ"], result:"ワラサ2〜3kg 船中15本 / イナダ多数", waterTempC:25.4,
    waterTempSource:"（サンプル）神奈川県水産技術センター 相模湾海況速報", weather:"晴れ", windMS:4, windDir:"SW", airTempC:32,
    sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s2", date:"2026-08-22", area:"wanko-miura", spot:"松輪・剣崎沖", spotType:"沖-釣り船", method:"ビシアジ",
    species:["アジ"], result:"25〜35cm 40〜80匹", waterTempC:24.8, waterTempSource:"（サンプル）",
    weather:"曇り", windMS:3, windDir:"S", airTempC:30, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s3", date:"2026-08-20", area:"aoku", spot:"横浜・大黒海づり施設", spotType:"釣り公園", method:"ちょい投げ",
    species:["シロギス","イワシ"], result:"キス15〜20cm ポツポツ / イワシ回遊", waterTempC:26.1, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:2, windDir:"SW", airTempC:33, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s4", date:"2026-07-15", area:"suruga", spot:"西伊豆・田子", spotType:"地磯", method:"ショアジギング",
    species:["ショゴ","カンパチ"], result:"ショゴ30〜40cm 3本", waterTempC:24.0, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:5, windDir:"S", airTempC:31, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s5", date:"2026-06-10", area:"sagami", spot:"茅ヶ崎・ヘッドランド", spotType:"砂浜", method:"ルアー",
    species:["ヒラメ","マゴチ"], result:"マゴチ50cm 1本", waterTempC:21.3, waterTempSource:"（サンプル）",
    weather:"曇り", windMS:4, windDir:"SW", airTempC:24, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s6", date:"2026-11-05", area:"wanko-miura", spot:"久里浜沖", spotType:"沖-釣り船", method:"タチウオテンヤ",
    species:["タチウオ"], result:"指2.5〜3.5本 10〜25匹", waterTempC:19.5, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:6, windDir:"N", airTempC:16, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s7", date:"2026-12-12", area:"sagami", spot:"真鶴・岩", spotType:"地磯", method:"ウキフカセ",
    species:["メジナ"], result:"30〜38cm 5枚", waterTempC:17.8, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:7, windDir:"NW", airTempC:12, sourceName:"（サンプル）", sourceUrl:"", note:"メジナはリスト外だが例として" },
  { id:"s8", date:"2026-09-18", area:"sagami", spot:"相模湾中央・沖", spotType:"沖-釣り船", method:"コマセ五目",
    species:["ブリ","ワラサ","マダイ"], result:"ワラサ〜ブリ級 船中8本 / マダイ2枚", waterTempC:25.0, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:3, windDir:"NE", airTempC:27, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s9", date:"2026-09-25", area:"suruga", spot:"沼津・静浦", spotType:"堤防", method:"エギング",
    species:["アオリイカ"], result:"胴長12〜18cm 3〜5杯", waterTempC:24.5, waterTempSource:"（サンプル）",
    weather:"曇り", windMS:2, windDir:"E", airTempC:24, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s10", date:"2026-10-08", area:"suruga", spot:"清水・三保", spotType:"砂浜", method:"ショアジギング",
    species:["ワカシ","ソウダガツオ"], result:"ワカシ30cm前後 / ソウダ回遊", waterTempC:23.2, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:5, windDir:"S", airTempC:22, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s11", date:"2026-01-20", area:"aoku", spot:"川崎・東扇島西公園", spotType:"釣り公園", method:"アジング",
    species:["アジ","メバル"], result:"アジ豆〜20cm / メバル15cm", waterTempC:12.5, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:4, windDir:"N", airTempC:8, sourceName:"（サンプル）", sourceUrl:"", note:"" },
  { id:"s12", date:"2026-05-03", area:"wanko-boso", spot:"内房・竹岡沖", spotType:"沖-釣り船", method:"コマセ",
    species:["マダイ","イサキ"], result:"マダイ0.8〜2kg 船中10枚", waterTempC:18.0, waterTempSource:"（サンプル）",
    weather:"晴れ", windMS:3, windDir:"SW", airTempC:22, sourceName:"（サンプル）", sourceUrl:"", note:"イサキはリスト外だが例" }
];
