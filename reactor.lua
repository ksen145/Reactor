local reactorSide, reactor, rodsLevel, reactorCap, CapArr
local monitorSide, monitor, h, w
local monitorSide1, monitor1, h1, w1

local function getPeripheral(name)
    local all = {}
    for i, v in pairs(peripheral.getNames()) do
        if(peripheral.getType(v) == name) then
            table.insert(all, v)
        end
    end
    return all
end

function sleep(ticks)
    local t = (1 / 20) * ticks
    os.sleep(t)
end

function sleepEvent()
    local t = (1 / 20) * 10
    os.sleep(t)
end

function event()
    local touch = os.pullEvent("monitor_touch")
    return 0
end

local function draw(CapArr, rodLevel, w, h)
    CapArr[1] = CapArr[2]
    for i = 2,(w-1) do
      CapArr[i] = CapArr[i+1]
      local y1 = math.floor(h/100*CapArr[i-1])
      local y2 = math.floor(h/100*CapArr[i])
      if y1 < 1 then
        y1 = 1
      elseif y1 > h then
        y1 = h
      end

      if y2 < 1 then
        y2 = 1
      elseif y2 > h then
        y2 = h
      end
      if i > 18 then
        paintutils.drawLine(i-1,y1,i,y2,colors.yellow)
      end
    end
    
    CapArr[w] = rodLevel
    local y1 = math.floor(h/100*CapArr[w-1])
    local y2 = math.floor(h/100*CapArr[w])
    if y1 < 1 then
        y1 = 1
    elseif y1 > h then
        y1 = h
    end

    if y2 < 1 then
        y2 = 1
    elseif y2 > h then
        y2 = h
    end

    paintutils.drawLine(h-1,y1,h,y2,colors.yellow)
    return CapArr
end

local function bar(monitor,reactor, counter)
    monitor.setCursorPos(1,1)
    if reactor.getActive() then
        monitor.write("Status:")
        monitor.setTextColor(colors.green)
        monitor.setCursorPos(8,1)
        monitor.write("Active")
        monitor.setTextColor(colors.orange)
    else
        monitor.write("Status:")
        monitor.setTextColor(colors.red)
        monitor.setCursorPos(8,1)
        monitor.write("Down")
        monitor.setTextColor(colors.orange)
    end
    monitor.setCursorPos(1,2)
    monitor.write("Work ticks:"..counter)
    monitor.setCursorPos(1,3)
    monitor.write("Energy:"..reactorCap)
    monitor.setCursorPos(1,4)
    monitor.write("RodsLevel:"..rodsLevel-1)
    monitor.setCursorPos(1,4)
    monitor.write("RF/Tick:"..reactor.getEnergyProducedLastTick())
end

reactorSide = getPeripheral("BigReactors-Reactor")
reactor = peripheral.wrap(reactorSide[1])

monitorSide = getPeripheral("monitor")
monitor = peripheral.wrap(monitorSide[1])

monitor.clear()

monitor.setTextScale(0.5)
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.orange)
monitor.setCursorPos(1,1)

w, h = monitor.getSize()
local counter = 0;

local oldTerm = term.redirect(monitor)

CapArr = {}
for i = 1,w do
    CapArr[i] = 0
  end

while true do

    rodsLevel = reactor.getControlRodLevel(1)

    reactorCap = reactor.getEnergyStored()

    local numFunc = parallel.waitForAny(event, sleepEvent)

    if (numFunc == 1) then
        break
    end

    if(reactorCap > reactor.getEnergyStored()) then
        reactor.setAllControlRodLevels(rodsLevel - 1)
    end
  
    if(reactorCap < reactor.getEnergyStored()) then
        reactor.setAllControlRodLevels(rodsLevel + 1)
    end

    if(reactorCap == 0) then
        reactor.setAllControlRodLevels(rodsLevel - 1)
    end

    if(reactorCap == 100) then
        reactor.setAllControlRodLevels(rodsLevel + 1)
    end

    monitor.clear()
    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setBackgroundColor(colors.black)
    counter = counter + 1

    bar(monitor, reactor, counter)

    CapArr = draw(CapArr, reactor.getControlRodLevel(1), w, h)
end

term.redirect(oldTerm)

monitor.clear()
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.orange)
monitor.clear()
monitor.setBackgroundColor(colors.black)
monitor.setTextColor(colors.orange)
monitor.setCursorPos(1,1)
monitor.write("exit")
