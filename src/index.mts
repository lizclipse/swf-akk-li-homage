import type { APIGatewayProxyHandlerV2 } from "aws-lambda";
import { readFileSync } from "fs";

const html = readFileSync("./index.html").toString("utf8");
const replace = "%SWF%";
const styles = "<!-- %STYLES% -->";

const pathParam = "swf";
const swfs = [
  "1rave",
  // "3ear", // Broken
  "56k",
  "404",
  "asiancry",
  "ass",
  "asshorn",
  "badapple",
  "banned",
  "car",
  "cookingbythebook",
  "dogs",
  "drunkensailor",
  "e54",
  "facepalm",
  "freddi",
  "icepunch",
  "jeff",
  "leek",
  "lolcats",
  "mad",
  "maze",
  // "music", // Broken
  "nitrado",
  "pi",
  "pirate",
  "pp",
  "rick",
  "tab",
  "toast",
  "troll",
  "waste",
  "whatislove",
] as const;

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  const param = event.pathParameters?.[pathParam];
  const swf = param || swfs[Math.floor(Math.random() * swfs.length)]!;
  return {
    statusCode: 200,
    body: html
      .replaceAll(replace, swf)
      .replaceAll(
        styles,
        param ? "<style> #lzp-rng, #dl { display: none; } </style>" : ""
      ),
    headers: {
      "Content-Type": "text/html; charset=utf-8",
    },
    cookies: [],
    isBase64Encoded: false,
  };
};
