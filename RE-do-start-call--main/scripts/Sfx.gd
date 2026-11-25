extends Reference

const RATE = 22050

var host = null
var players = []
var streams = {}
var specs = {}
var next_player = 0
var enabled = true
var volume_db = -8.0


func setup(node, on, vol):
    host = node
    enabled = on
    volume_db = vol
    for i in range(10):
        var p = AudioStreamPlayer.new()
        p.volume_db = vol
        node.add_child(p)
        players.append(p)
    build_specs()


func set_enabled(on):
    enabled = on
    if not on:
        for p in players:
            if p.playing:
                p.stop()


func L(kind, f0, f1, dur, gain, decay, lp):
    return {"kind": kind, "f0": f0, "f1": f1, "dur": dur, "gain": gain, "decay": decay, "lp": lp}


func build_specs():
    specs["ui"] = [L("sine", 170.0, 110.0, 0.07, 0.50, 3.0, 0.0), L("noise", 1.0, 1.0, 0.03, 0.18, 4.0, 1400.0)]
    specs["deny"] = [L("sine", 90.0, 55.0, 0.18, 0.70, 2.4, 0.0), L("noise", 1.0, 1.0, 0.09, 0.28, 3.0, 520.0)]
    specs["step"] = [L("sine", 105.0, 46.0, 0.15, 0.80, 2.8, 0.0), L("noise", 1.0, 1.0, 0.06, 0.22, 3.5, 420.0)]
    specs["dash"] = [L("sine", 155.0, 50.0, 0.24, 0.95, 2.0, 0.0), L("noise", 1.0, 1.0, 0.17, 0.42, 2.2, 2100.0)]
    specs["shoot"] = [L("sine", 200.0, 60.0, 0.17, 0.90, 2.4, 0.0), L("noise", 1.0, 1.0, 0.10, 0.50, 3.0, 3400.0)]
    specs["lob"] = [L("sine", 120.0, 58.0, 0.32, 0.82, 1.8, 0.0), L("noise", 1.0, 1.0, 0.26, 0.30, 1.6, 800.0)]
    specs["crack"] = [L("sine", 150.0, 38.0, 0.34, 1.00, 2.0, 0.0), L("noise", 1.0, 1.0, 0.13, 0.68, 3.0, 2600.0), L("tri", 500.0, 160.0, 0.16, 0.34, 2.4, 1800.0)]
    specs["saber"] = [L("sine", 76.0, 40.0, 0.54, 1.00, 1.3, 0.0), L("tri", 170.0, 86.0, 0.42, 0.34, 1.5, 1150.0), L("noise", 1.0, 1.0, 0.36, 0.34, 1.4, 1600.0)]
    specs["hit"] = [L("sine", 138.0, 42.0, 0.28, 0.95, 2.2, 0.0), L("noise", 1.0, 1.0, 0.10, 0.52, 3.2, 1150.0)]
    specs["crit"] = [L("sine", 100.0, 28.0, 0.50, 1.00, 1.7, 0.0), L("noise", 1.0, 1.0, 0.17, 0.66, 2.4, 2800.0), L("tri", 440.0, 130.0, 0.24, 0.36, 2.0, 1700.0)]
    specs["hurt"] = [L("sine", 165.0, 36.0, 0.42, 1.00, 1.8, 0.0), L("noise", 1.0, 1.0, 0.22, 0.48, 2.0, 720.0)]
    specs["block"] = [L("sine", 215.0, 76.0, 0.24, 0.88, 2.2, 0.0), L("noise", 1.0, 1.0, 0.10, 0.38, 3.0, 1550.0)]
    specs["boom"] = [L("sine", 86.0, 24.0, 0.72, 1.00, 1.5, 0.0), L("noise", 1.0, 1.0, 0.52, 0.60, 1.7, 540.0), L("tri", 145.0, 46.0, 0.36, 0.30, 2.0, 720.0)]
    specs["glass"] = [L("sine", 128.0, 44.0, 0.26, 0.84, 2.0, 0.0), L("noise", 1.0, 1.0, 0.32, 0.50, 1.8, 5400.0)]
    specs["acid"] = [L("sine", 96.0, 46.0, 0.34, 0.76, 1.8, 0.0), L("noise", 1.0, 1.0, 0.30, 0.40, 1.5, 950.0)]
    specs["reload"] = [L("sine", 148.0, 66.0, 0.12, 0.74, 2.6, 0.0), L("noise", 1.0, 1.0, 0.05, 0.36, 3.4, 2300.0)]
    specs["heal"] = [L("sine", 168.0, 305.0, 0.34, 0.68, 1.4, 0.0), L("tri", 335.0, 610.0, 0.26, 0.17, 1.8, 2300.0)]
    specs["coin"] = [L("sine", 305.0, 190.0, 0.13, 0.62, 2.4, 0.0), L("noise", 1.0, 1.0, 0.07, 0.30, 3.0, 3500.0)]
    specs["trap"] = [L("sine", 132.0, 30.0, 0.52, 0.98, 1.6, 0.0), L("noise", 1.0, 1.0, 0.30, 0.54, 1.9, 920.0)]
    specs["boss"] = [L("sine", 58.0, 21.0, 1.20, 1.00, 1.1, 0.0), L("noise", 1.0, 1.0, 1.00, 0.50, 1.4, 330.0), L("tri", 94.0, 36.0, 0.80, 0.30, 1.3, 520.0)]
    specs["telegraph"] = [L("sine", 68.0, 44.0, 0.32, 0.62, 1.6, 0.0), L("noise", 1.0, 1.0, 0.22, 0.20, 2.0, 320.0)]
    specs["win"] = [L("sine", 96.0, 195.0, 0.84, 0.92, 1.1, 0.0), L("tri", 225.0, 450.0, 0.64, 0.25, 1.4, 2500.0)]
    specs["lose"] = [L("sine", 122.0, 24.0, 1.05, 1.00, 1.2, 0.0), L("noise", 1.0, 1.0, 0.70, 0.40, 1.5, 430.0)]


func render(spec):
    var total = 0.0
    for l in spec:
        total = max(total, l["dur"])
    var n = int(total * RATE) + 2
    var buf = PoolRealArray()
    buf.resize(n)
    for i in range(n):
        buf.set(i, 0.0)

    for l in spec:
        var ln = int(l["dur"] * RATE)
        if ln < 2:
            ln = 2
        var phase = 0.0
        var lp_state = 0.0
        var a = 1.0
        if l["lp"] > 0.0:
            a = 1.0 - exp(-TAU * l["lp"] / float(RATE))
        var f0 = max(1.0, l["f0"])
        var f1 = max(1.0, l["f1"])
        var ratio = f1 / f0
        var attack_n = max(1.0, RATE * 0.003)
        for i in range(ln):
            var t = float(i) / float(ln)
            var f = f0 * pow(ratio, t)
            phase += f / float(RATE)
            while phase > 1.0:
                phase -= 1.0
            var s = 0.0
            if l["kind"] == "noise":
                s = randf() * 2.0 - 1.0
            elif l["kind"] == "tri":
                s = 4.0 * abs(phase - 0.5) - 1.0
            else:
                s = sin(phase * TAU)
            if l["lp"] > 0.0:
                lp_state += (s - lp_state) * a
                s = lp_state
            var env = pow(1.0 - t, l["decay"])
            var atk = min(1.0, float(i) / attack_n)
            buf.set(i, buf[i] + s * env * atk * l["gain"])

    var bytes = PoolByteArray()
    bytes.resize(n * 2)
    var tail_n = max(1.0, RATE * 0.010)
    for i in range(n):
        var s2 = buf[i] * 1.7
        s2 = s2 / (1.0 + abs(s2) * 0.55)
        s2 *= 0.88
        var tail = float(n - i) / tail_n
        if tail < 1.0:
            s2 *= tail
        var v = int(clamp(s2, -1.0, 1.0) * 30000.0)
        bytes.set(i * 2, v & 0xFF)
        bytes.set(i * 2 + 1, (v >> 8) & 0xFF)

    var st = AudioStreamSample.new()
    st.format = AudioStreamSample.FORMAT_16_BITS
    st.mix_rate = RATE
    st.stereo = false
    st.data = bytes
    return st


func play(key, pitch = 1.0):
    if not enabled or host == null:
        return
    if not specs.has(key):
        return
    if not streams.has(key):
        streams[key] = render(specs[key])
    if players.empty():
        return
    var p = players[next_player]
    next_player = (next_player + 1) % players.size()
    p.stream = streams[key]
    p.pitch_scale = clamp(pitch * rand_range(0.97, 1.03), 0.25, 3.0)
    p.volume_db = volume_db
    p.play()