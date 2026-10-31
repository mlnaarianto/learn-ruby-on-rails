FROM ruby:4.0.5

# 1. Install dependensi sistem
# Menambahkan 'rm -rf /var/lib/apt/lists/*' agar ukuran image tidak terlalu besar
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    nodejs \
    npm \
    git \
    curl \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Yarn
RUN npm install -g yarn

# 3. Set working directory
WORKDIR /app

# 4. Konfigurasi Bundler untuk koneksi yang tidak stabil
# Ini adalah kunci agar tidak "ngestack" saat unduh gem
RUN bundle config set --global retry 5 && \
    bundle config set --global timeout 60

# 5. Copy Gemfile dan install gems
# '--jobs 4' membuat proses instalasi paralel (lebih cepat)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

# 6. Copy sisa kode aplikasi
COPY . .

# 7. Buat appuser & FIX PERMISSION
# Pastikan folder tmp/pids, log, dan storage dibuat dan bisa ditulis oleh appuser
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -m -s /bin/bash appuser && \
    mkdir -p /app/tmp/pids /app/log /app/storage && \
    chown -R appuser:appuser /app /usr/local/bundle

# 8. Gunakan non-root user
USER appuser

# 9. Expose port (Opsional, hanya sebagai dokumentasi)
EXPOSE 3000