# coding: utf-8
class Umgyoh
  require "socket"
  require "json"

  # umgyoh pid ファイル
  UMGYOH_PID_FILE = "./tmp/umgyoh.pid".freeze
  # umgyoh log ファイル
  UMGYOH_LOG_FILE = "./tmp/umgyoh.log".freeze
  # umgyoh デフォルトポート番号
  UMGYOH_DEFAULT_PORT = 2019

  # 初期化処理
  def initialize
    # pid ファイル作成
    File.open(UMGYOH_PID_FILE, "w").close
    # log ファイル作成
    File.open(UMGYOH_LOG_FILE, "a+").close
  end

  # 起動
  def run
    begin
      log_info("== Umgyoh Begin.")

      # デーモン化
      daemonize

      # 処理実行
      execute

      log_info("== Umgyoh End.")
    rescue => e
    end
  end

  private

  # デーモン化
  def daemonize
    begin
      # デーモン化
      Process.daemon(true, true)

      # pid ファイル生成
      File.open(UMGYOH_PID_FILE, "w") { |f| f << Process.pid }
    rescue => e
      error_message = "#{self.class.name}.daemonize #{e}"
      log_error(error_message)
      STDERR.puts(error_message)
      exit(1)
    end
  end

  # 処理実行
  def execute
    @tcp_server = TCPServer.open(UMGYOH_DEFAULT_PORT)

    while true
      # 接続要求を受け付ける TCPSocket を生成。
      socket = @tcp_server.accept

      # 接続相手先ソケットの情報。
      peeraddr = socket.peeraddr
      log_info("socket.peeraddr => #{peeraddr}")

      # クライアントからのデータを全て受け取る。
      while json = socket.gets
        log_info("json => #{json}")
        begin
          hash = JSON.parse(json)
        rescue => e
          log_error("#{e.message}")
        end
        log_info("hash => #{hash.inspect}")

        socket.puts("200")
      end

      # TCPSocket を閉じる。
      socket.close
    end
  end

  # 停止処理
  def stop
    @tcp_server.close
  end

  # ロガー
  def log_info(message = '')
    now = Time.now
    File.open(UMGYOH_LOG_FILE, "a+") do |f|
      f.puts("[#{now}] #{message}")
    end
  end

  def log_error(message = '')
    log_info("[ERROR] #{message}")
  end
end

# 起動
Umgyoh.new.run
