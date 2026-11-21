export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=90

# Huggingface
export HF_HUB_CACHE="$HOME/models/huggingface" 

# Llama.cpp
export LLAMA_ARG_HOST=127.0.0.1
export LLAMA_ARG_PORT=4101

# LM Studio
export LMS_SERVER_HOST=127.0.0.1
# configured port '4102' in .lmstudio/.internal/http-server-config.json
export PATH="$PATH:$HOME/.lmstudio/bin"

# Ollama
export OLLAMA_HOST=127.0.0.1:4103
export OLLAMA_MODELS="$HOME/models/ollama"

# oMLX
# host: 127.0.0.1, port: 4104
# api_key: OMLX_API_KEY
# models: $HOME/.omlx/models
