macbook = {
  { 'Firefox Developer Edition', nil, nil, hs.layout.maximized, nil, nil },
  { 'Safari', nil, nil, hs.layout.maximized, nil, nil },
  { 'Brave Browser', nil, nil, hs.layout.maximized, nil, nil },
  { 'WezTerm', nil, nil, hs.layout.maximized, nil, nil },
  { 'Slack', nil, nil, hs.layout.maximized, nil, nil },
  { 'Telegram', nil, nil, hs.layout.right50, nil, nil },
  { 'Messages', nil, nil, hs.layout.right50, nil, nil },
  { 'TablePlus', nil, nil, nil, nil, hs.geometry.rect(200, 44, 1400, 986) },
  { 'Fantastical', nil, nil, hs.layout.maximized, nil, nil },
  { 'Things', nil, nil, nil, nil, hs.geometry.rect(354, 338, 935, 700) },
  { 'Spotify', nil, nil, hs.layout.maximized, nil, nil },
  { 'Discord', nil, nil, hs.layout.maximized, nil, nil },
  { 'Bear', nil, nil, hs.layout.maximized, nil, nil },
  { 'Anybox', nil, nil, hs.layout.maximized, nil, nil },
  { 'Beeper', nil, nil, hs.layout.right50, nil, nil },
  { 'Visual Studio Code', nil, nil, hs.layout.maximized, nil, nil },
}

dell = {
  { 'Firefox Developer Edition', nil, nil, hs.layout.left50, nil, nil },
  { 'Safari', nil, nil, hs.layout.left50, nil, nil },
  { 'Brave Browser', nil, nil, hs.layout.left50, nil, nil },
  { 'WezTerm', nil, nil, hs.layout.right50, nil, nil },
  { 'Slack', nil, nil, hs.layout.left50, nil, nil },
  { 'Telegram', 'Telegram', nil, hs.layout.right30, nil, nil },
  { 'Messages', nil, nil, hs.layout.right30, nil, nil },
  { 'TablePlus', nil, nil, nil, nil, hs.geometry.rect(200, 44, 1400, 986) },
  { 'Fantastical', nil, nil, nil, nil, hs.geometry.rect(1090, 129, 1608, 1102) },
  { 'Things', nil, nil, nil, nil, hs.geometry.rect(588, 555, 935, 700) },
  { 'Spotify', nil, nil, nil, nil, hs.geometry.rect(1518, 312, 1800, 986) },
  { 'Discord', nil, nil, hs.layout.right50, nil, nil },
  { 'Bear', nil, nil, hs.layout.left30, nil, nil },
  { 'Anybox', nil, nil, nil, nil, hs.geometry.rect(965, 313, 1430, 1079) },
  { 'Beeper', nil, nil, hs.layout.right30, nil, nil },
  { 'Visual Studio Code', nil, nil, hs.layout.left50, nil, nil },
}

function screenDetect()
  -- redneck engineering to wait so window load doesn't fail
  time = os.time()
  wait = 2
  newtime = time + wait
  while time < newtime do
    time = os.time()
  end

  if hs.screen('Built%-in') then
    hs.layout.apply(macbook)
  elseif hs.screen('Dell') then
    hs.layout.apply(dell)
  else
    print('Nothing to do.')
  end

  print('Screens rearranged.')
end

screenWatcher = hs.screen.watcher.new(screenDetect)
screenWatcher:start()
