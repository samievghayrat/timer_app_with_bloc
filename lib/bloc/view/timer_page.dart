import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ticker.dart';
import '../timer_bloc.dart';
import '../timer_state.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ],
        ),
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.headline1,
    );
  }
}

class Actions extends StatefulWidget {
  const Actions({Key? key}) : super(key: key);

  @override
  _ActionsState createState() => _ActionsState();
}

class _ActionsState extends State<Actions> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildActionButtons(state),
        );
      },
    );
  }

  List<Widget> _buildActionButtons(TimerState state) {
    if (state is TimerInitial) {
      return [
        FloatingActionButton(
          child: const Icon(Icons.play_arrow),
          onPressed: () => context.read<TimerBloc>().add(
                TimerStarted(duration: state.duration),
              ),
        ),
      ];
    } else if (state is TimerRunInProgress) {
      return [
        FloatingActionButton(
          child: const Icon(Icons.pause),
          onPressed: () => context.read<TimerBloc>().add(const TimerPaused()),
        ),
        FloatingActionButton(
          child: const Icon(Icons.replay),
          onPressed: () => context.read<TimerBloc>().add(const TimerReset()),
        ),
      ];
    } else if (state is TimerRunPause) {
      return [
        FloatingActionButton(
          child: const Icon(Icons.play_arrow),
          onPressed: () => context.read<TimerBloc>().add(const TimerResumed()),
        ),
        FloatingActionButton(
          child: const Icon(Icons.replay),
          onPressed: () => context.read<TimerBloc>().add(const TimerReset()),
        ),
      ];
    } else if (state is TimerRunComplete) {
      return [
        FloatingActionButton(
          child: const Icon(Icons.replay),
          onPressed: () => context.read<TimerBloc>().add(const TimerReset()),
        ),
      ];
    } else {
      return [];
    }
  }
}
