/*
 *  qrTypeDefs.h
 *  Quarto
 *
 *  Created by Jonathan Nobels on 10-09-28.
 *  Copyright 2010 Barn*Star Studios. All rights reserved.
 *
 */

typedef enum{
	singlePlayer = 1,
	twoPlayerDevice,
	twoPlayerLocal,
	twoPlayerNetwork,
	twoPlayerGameKit
}qrGameType;


typedef enum {
	kqrDifficultyEasy = 1,
	kqrDifficultyMed,
	kqrDifficultyHard
}qrDifficulty;

typedef enum {
	playerStart = 1,
	computerStart,
	randomStart
}qrFirstMove;