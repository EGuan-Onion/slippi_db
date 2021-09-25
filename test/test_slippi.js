const { SlippiGame } = require("@slippi/slippi-js");

let g0 = new SlippiGame('./test/replays/Game_20200630T004406.slp')
let g1 = new SlippiGame('./test/replays/Game_20210906T143335.slp')
// let g1 = new SlippiGame('/Volumes/T7/slippi_db/replays/onion_slp/202006_to_202109/Game_20210908T142655.slp')

console.log(g0.getMetadata().players[0].names)
console.log(g1.getSettings().players[0].connectCode)