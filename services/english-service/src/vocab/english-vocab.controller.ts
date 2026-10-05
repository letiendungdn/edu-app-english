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
import {
  CurrentEnglishUser,
  type EnglishAuthRequest,
  type EnglishUserPayload,
} from "../auth/english-current-user.decorator";
import {
  EnglishAuthGuard,
  EnglishOptionalAuthGuard,
} from "../auth/english-auth.guard";
import { EnglishVocabService } from "./english-vocab.service";

@Public()
@RawResponse()
@Controller("api/english/vocab")
export class EnglishVocabController {
  constructor(private readonly vocabService: EnglishVocabService) {}

  @Get()
  @UseGuards(EnglishOptionalAuthGuard)
  list(
    @Query("level") level: string | undefined,
    @Query("topicId") topicId: string | undefined,
    @Query("page") page: string | undefined,
    @Query("limit") limit: string | undefined,
    @Req() req: EnglishAuthRequest,
  ) {
    return this.vocabService.list(level, topicId, page, limit, req.englishUser);
  }

  @Get("picture")
  picture(
    @Query("level") level: string | undefined,
    @Query("topicId") topicId: string | undefined,
    @Query("picturesOnly") picturesOnly: string | undefined,
    @Query("limit") limit: string | undefined,
  ) {
    return this.vocabService.picture(level, topicId, picturesOnly, limit);
  }

  @Get("review")
  @UseGuards(EnglishAuthGuard)
  getReview(@CurrentEnglishUser() user: EnglishUserPayload) {
    return this.vocabService.getReviewQueue(user.id);
  }

  @Post("review")
  @UseGuards(EnglishAuthGuard)
  submitReview(
    @CurrentEnglishUser() user: EnglishUserPayload,
    @Body() body: { vocabId: number; quality: number },
  ) {
    return this.vocabService.submitReview(user.id, body.vocabId, body.quality);
  }
}
