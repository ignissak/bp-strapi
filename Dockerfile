FROM node:22-alpine AS base
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm i -P --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm i --frozen-lockfile
RUN pnpm build

FROM base
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build app/dist ./dist
EXPOSE 1337
CMD ["pnpm", "start"]