import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/synora_header.dart';
import '../../widgets/glass_container.dart';

class BudgetOverviewScreen extends StatelessWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final eventId = eventProvider.selectedEventId;
    final event = eventProvider.selectedEvent;

    if (eventId == null || event == null) {
      return const Scaffold(
        body: Column(
          children: [
            SynoraHeader(title: 'Budget Overview'),
            Expanded(child: Center(child: Text('Please select an event from the dashboard.'))),
          ],
        ),
      );
    }

    final budget = budgetProvider.getBudgetForEvent(eventId);
    final expenses = budgetProvider.getExpensesForEvent(eventId);

    if (budget == null) {
      return const Scaffold(
        body: Column(
          children: [
            SynoraHeader(title: 'Budget Overview'),
            Expanded(child: Center(child: Text('No budget found for this event.'))),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Budget Overview',
            subtitle: 'Track your event expenses',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalBudgetCard(context, budget),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Smart Insights', Icons.auto_awesome),
                  const SizedBox(height: 12),
                  _buildBudgetInsights(event, budget, expenses),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Category recommendations', Icons.lightbulb_outline),
                  const SizedBox(height: 12),
                  _buildRecommendationVisual(event.type, budget.totalBudget, event.requiredServices),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Spending Breakdown', Icons.pie_chart_outline),
                  const SizedBox(height: 16),
                  _buildCategoryDistribution(context, expenses, budget.totalBudget),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Recent Expenses', Icons.history),
                  const SizedBox(height: 16),
                  _buildRecentExpensesList(context, expenses),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTotalBudgetCard(BuildContext context, var budget) {
    final utilization = budget.totalBudget > 0 ? budget.spentAmount / budget.totalBudget : 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Color(0xFF6A11CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Budget', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text('₹${budget.totalBudget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat('Spent', '₹${budget.spentAmount.toStringAsFixed(0)}'),
              _buildSimpleStat('Remaining', '₹${budget.remainingAmount.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: utilization > 1.0 ? 1.0 : utilization,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(utilization > 0.9 ? Colors.orangeAccent : Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(utilization * 100).toStringAsFixed(1)}% used',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBudgetInsights(dynamic event, dynamic budget, List expenses) {
    // Simple rule-based logic
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final recommendations = _getRecommendationsForType(event.type, event.requiredServices);
    List<Widget> insightWidgets = [];

    recommendations.forEach((cat, percent) {
      final recommendedAmount = budget.totalBudget * (percent / 100);
      final actualSpent = categoryTotals[cat] ?? 0;
      
      if (actualSpent > recommendedAmount) {
        insightWidgets.add(_buildInsightItem(
          'Overspending in $cat!',
          'You spent ₹${actualSpent.toStringAsFixed(0)} which is more than the recommended ₹${recommendedAmount.toStringAsFixed(0)}.',
          Colors.red,
        ));
      } else if (actualSpent > 0 && actualSpent < recommendedAmount * 0.5) {
        insightWidgets.add(_buildInsightItem(
          'Saving in $cat',
          'Great! You are well within the budget for $cat.',
          Colors.green,
        ));
      }
    });

    if (insightWidgets.isEmpty) {
      return const GlassContainer(child: Padding(padding: EdgeInsets.all(16), child: Text('No insights yet. Add more expenses to see trends.')));
    }

    return Column(children: insightWidgets);
  }

  Widget _buildInsightItem(String title, String message, Color color) {
    return GlassContainer(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(message, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildRecommendationVisual(String eventType, double totalBudget, List<String> requiredServices) {
    final recommendations = _getRecommendationsForType(eventType, requiredServices);
    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.pink];
    
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 20,
                child: Row(
                  children: recommendations.entries.map((e) {
                    final index = recommendations.keys.toList().indexOf(e.key);
                    return Expanded(
                      flex: e.value.toInt(),
                      child: Container(color: colors[index % colors.length]),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: recommendations.entries.map((e) {
                final index = recommendations.keys.toList().indexOf(e.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: colors[index % colors.length], shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('${e.key}: ${e.value}%', style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution(BuildContext context, List expenses, double totalBudget) {
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    if (categoryTotals.isEmpty) return const Text('No data.');

    return Column(
      children: categoryTotals.entries.map((e) {
        final percent = (e.value / totalBudget * 100).toStringAsFixed(1);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('₹${e.value.toStringAsFixed(0)} ($percent%)', style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: e.value / totalBudget,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentExpensesList(BuildContext context, List expenses) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses recorded yet.'));
    }
    return Column(
      children: expenses.take(5).map<Widget>((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildExpenseItem(
            context,
            e.description ?? 'Expense',
            e.date != null ? '${e.date.day}/${e.date.month}/${e.date.year}' : '',
            '₹${e.amount.toStringAsFixed(0)}',
            Icons.receipt_long_outlined,
          ),
        );
      }).toList(),
    );
  }

  Map<String, double> _getRecommendationsForType(String type, List<String> requiredServices) {
    // If we have specific required services, distribute budget among them
    if (requiredServices.isNotEmpty) {
      final Map<String, double> recs = {};
      double remaining = 100.0;
      
      // Basic weighted distribution
      if (requiredServices.contains('venue')) { recs['Venue'] = 40; remaining -= 40; }
      if (requiredServices.contains('catering')) { recs['Catering'] = 30; remaining -= 30; }
      if (requiredServices.contains('photography')) { recs['Photography'] = 15; remaining -= 15; }
      
      if (remaining > 0) {
        recs['Others'] = remaining;
      }
      return recs;
    }

    // Fallback to type-based defaults
    switch (type) {
      case 'Wedding':
        return {'Venue': 40, 'Catering': 30, 'Photography': 15, 'Others': 15};
      case 'Birthday':
        return {'Decoration': 30, 'Catering': 40, 'Photography': 10, 'Others': 20};
      default:
        return {'Venue': 30, 'Catering': 40, 'Others': 30};
    }
  }

  Widget _buildExpenseItem(BuildContext context, String title, String date, String amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
