import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
} from "@nestjs/common";
import { Public, RawResponse } from "@app/common";
import type { EnglishAuthRequest } from "../auth/english-current-user.decorator";
import { EnglishOptionalAuthGuard } from "../auth/english-auth.guard";
import { EnglishDictationService } from "./english-dictation.service";

@Public()
@RawResponse()
@Controller("api/english/dictation")
export class EnglishDictationController {
  constructor(private readonly dictationService: EnglishDictationService) {}

  @Get()
  listWords(
    @Query("level") level: string | undefined,
    @Query("topicId") topicId: string | undefined,
    @Query("limit") limit: string | undefined,
  ) {
    return this.dictationService.listWords(level, topicId, limit);
  }

  @Post()
  @UseGuards(EnglishOptionalAuthGuard)
  recordAttempt(
    @Body()
    body: { vocabId: number; userInput: string; correct: boolean },
    @Req() req: EnglishAuthRequest,
  ) {
    return this.dictationService
      .recordAttempt(
        body.vocabId,
        body.userInput,
        body.correct,
        req.englishUser,
      )
      .then(() => ({ ok: true }));
  }
}
