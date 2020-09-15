# Insane Nights at Snowball's

Este é o código fonte do INaS. Ele foi escrito em Lua usando a [framework LÖVE](https://love2d.org). Pode haver alguns códigos confusos aqui e ali, mas sinta-se à vontade para usar algumas partes do código em seu próprio projeto (desde que você não roube todo o código e diga que você que fez). Se você quiser usar qualquer uma das renders, entre em contato com o modelador: [Th3 Atomic](https://gamejolt.com/@Th3_Atomic_Official).

# Compilação

### Windows

1. Baixe o executável do LÖVE aqui (recomendo o 32-bits, mas o 64-bits também deve funcionar).

2. Extraia todos os arquivos em algum lugar ou instale se você baixou o instalador.

3. Clone ou baixe este repositório em algum lugar do seu PC e compacte-o usando qualquer software de compressão. Tenha certeza de que todos os arquivos do jogo (especialmente "main.lua") estão na raiz do arquivo, e não em uma subpasta.

4. Renomeie o arquivo zip para "inasgame.love" e mova-o para a mesma pasta do executável do LÖVE.

5. Abra o prompt de comando e digite:

```bash
cd "caminho/para/a/pasta/do/love"
copy /b love.exe+inasgame.love inas.exe
```

6. Crie uma nova pasta em algum lugar e copie o "inas.exe", "license.txt" e todos os arquivos dll para ela.

7. Vá para o [repositório do Discord RPC](https://github.com/discord/discord-rpc) e compile ou baixe uma dll pré-compilada em "releases".

8. Mova o "discord-rpc.dll" para a mesma pasta do "inas.exe".

### Outras plataformas

Mais informações sobre como compilar para outras plataformas na [wiki do LÖVE](https://love2d.org/wiki/Game_Distribution). Algumas mudanças no código podem ser necessárias para torná-lo compatível com todas as plataformas.

# Credits

Programação: [FloatingBanana](https://gamejolt.com/@FloatingBanana)
Modelagem: [Th3 Atomic](https://gamejolt.com/@Th3_Atomic_Official)


##### Bibliotecas

* [Bump.lua](https://github.com/kikito/bump.lua)
* [lua-discordRPC](https://github.com/pfirsich/lua-discordRPC)
* [FPSGraph](https://github.com/icrawler/FPSGraph)
* [Gamejolt.lua](https://github.com/mbrovko/gamejoltlua)
* [HUMP](https://github.com/HDictus/hump/tree/temp-master)
* [Lily](https://github.com/MikuAuahDark/lily)
* [Lume](https://github.com/rxi/lume/)
* [Moonshine](https://github.com/vrld/moonshine)
* [Slab](https://github.com/coding-jackalope/Slab)
* [Kuey](https://love2d.org/wiki/Kuey)

##### Recursos

* Jesús Lastra - [Abandoned](https://opengameart.org/content/collaboration-theme-song-abandoned)

* Anthon - [We are Safe](https://opengameart.org/content/we-are-safe)

* Scocapex - [Dark ambiance](https://opengameart.org/content/dark-ambiance)

* Yd - [Insistent](https://opengameart.org/content/insistent-background-loop)

* AlexTheDj - [Heavy Terror Machine](https://www.newgrounds.com/audio/listen/345935)

# Licensa

Este projeto está publicado sob a licensa MIT.