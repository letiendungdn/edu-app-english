import { Injectable, OnModuleInit } from "@nestjs/common";
import { PrismaClient } from "@edu/prisma-english/client";

@Injectable()
export class EnglishPrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect();
  }
}
